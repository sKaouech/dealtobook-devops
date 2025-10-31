#!/bin/bash
set -euo pipefail

# Usage:
#   restore-from-backup.sh /opt/dealtobook-dev/backups/postgres-YYYYMMDD-HHMMSS [container] [pguser] [--reset]
# Restores databases into dealtobook-postgres container.

BACKUP_DIR=${1:-}
CONTAINER=${2:-dealtobook-postgres}
# PGUSER provided is optional; will be auto-detected from container if not set
PGUSER_DEFAULT=${3:-}
RESET_FLAG=${4:-}

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ Backup directory is missing: $BACKUP_DIR" >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "❌ Container not running: $CONTAINER" >&2
  exit 1
fi

# Detect credentials from container environment
PGUSER_IN_CONTAINER=$(docker exec "$CONTAINER" sh -lc 'printf "%s" "$POSTGRES_USER"' 2>/dev/null || true)
PGPASS_IN_CONTAINER=$(docker exec "$CONTAINER" sh -lc 'printf "%s" "$POSTGRES_PASSWORD"' 2>/dev/null || true)

if [ -n "${PGUSER_DEFAULT}" ]; then
  PGUSER="$PGUSER_DEFAULT"
else
  PGUSER="${PGUSER_IN_CONTAINER:-dealtobook}"
fi
PGPASSWORD_VALUE="${PGPASS_IN_CONTAINER:-}"

if [ -z "$PGPASSWORD_VALUE" ]; then
  echo "⚠️  POSTGRES_PASSWORD not found in container env. Continuing without password (trust/md5 w/.pgpass may be required)."
fi

DBS=(dealtobook_db deal_setting deal_generator keycloak)

# Helper to run inside container with password
execc() {
  docker exec -e PGPASSWORD="$PGPASSWORD_VALUE" "$CONTAINER" sh -lc "$*"
}

# Performance tuning during restore (temporary at session-level for safety)
apply_perf_pragmas() {
  local db="$1"
  execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '$db' -c \"ALTER SYSTEM SET maintenance_work_mem='256MB';\"" || true
  execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '$db' -c \"ALTER SYSTEM SET synchronous_commit='off';\"" || true
}

revert_perf_pragmas() {
  local db="$1"
  execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '$db' -c \"ALTER SYSTEM RESET maintenance_work_mem;\"" || true
  execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '$db' -c \"ALTER SYSTEM RESET synchronous_commit;\"" || true
}

echo "👤 Using DB user: $PGUSER"
[ -n "$PGPASSWORD_VALUE" ] && echo "🔑 Password: (from container env)"

echo "📁 Using backup directory: $BACKUP_DIR"
WORKDIR_IN_CONTAINER="/tmp/restore_$(date +%s)"
execc "mkdir -p '$WORKDIR_IN_CONTAINER' && chmod 700 '$WORKDIR_IN_CONTAINER'"

echo "📦 Copying backup files into container..."
# Copy files - docker cp preserves directory structure, so we need to flatten it
docker cp "$BACKUP_DIR/." "$CONTAINER:$WORKDIR_IN_CONTAINER/"

# Flatten structure: move files from subdirectories to root of WORKDIR_IN_CONTAINER
echo "📁 Flattening backup structure..."
execc "
  cd '$WORKDIR_IN_CONTAINER' || exit 1
  # Find all subdirectories and move their contents to root
  for subdir in */; do
    if [ -d \"\$subdir\" ] && [ \"\$(basename \"\$subdir\")\" != '.tmp' ]; then
      echo \"  Moving files from subdir: \$(basename \"\$subdir\")\"
      mv \"\$subdir\"* . 2>/dev/null || true
      rmdir \"\$subdir\" 2>/dev/null || true
    fi
  done
  # Verify files are now in root
  echo \"  Files in workdir root:\"
  ls -1 . | head -10 || true
"

# Optional reset: drop and recreate DBs
if [ "$RESET_FLAG" = "--reset" ]; then
  echo "🧨 Reset mode enabled: dropping and recreating databases..."
  for db in "${DBS[@]}"; do
    execc "psql -U '$PGUSER' -d postgres -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}' AND pid <> pg_backend_pid();\" 2>/dev/null || true"
    execc "psql -U '$PGUSER' -d postgres -c \"DROP DATABASE IF EXISTS \"\"${db}\"\";\""
  done
fi

# Ensure createdb utility exists (should be in postgres image)
execc "command -v createdb >/dev/null 2>&1" || { echo "❌ 'createdb' not found in container"; exit 1; }

echo "🗃️ Ensuring databases exist..."
for db in "${DBS[@]}"; do
  if execc "psql -U '$PGUSER' -d postgres -tAc \"SELECT 1 FROM pg_database WHERE datname='${db}'\" | grep -q 1"; then
    echo "  ✓ ${db} exists"
  else
    echo "  + Creating ${db}..."
    execc "createdb -U '$PGUSER' -O '$PGUSER' '${db}'" || { echo "  ⚠️  createdb failed for ${db}"; exit 1; }
    execc "psql -U '$PGUSER' -d postgres -c \"GRANT ALL PRIVILEGES ON DATABASE \"\"${db}\"\" TO ${PGUSER};\"" || true
    echo "  ✅ ${db} created"
  fi
  # Apply performance pragmas
  apply_perf_pragmas "$db"
done

# Select best backup file with priority: dump/tar > sql.gz > sql; ignore tiny .sql (<1MB)
choose_backup_file() {
  local db="$1"
  local pick=""
  
  # Priority 1: dump/tar (custom format)
  for ext in dump tar; do
    # Use find or ls with grep to match files containing db name
    pick=$(execc "ls -1 '$WORKDIR_IN_CONTAINER' 2>/dev/null | grep -i '${db}' | grep -i '\.${ext}\$' | head -n1" || echo "")
    if [ -n "$pick" ] && [ "$pick" != "" ]; then
      echo "$pick"
      return 0
    fi
  done
  
  # Priority 2: sql.gz (compressed) - most common format
  # Match patterns like: deal_setting_backup.sql.gz, keycloak_backup.sql.gz
  pick=$(execc "ls -1 '$WORKDIR_IN_CONTAINER' 2>/dev/null | grep -i '${db}' | grep -i '\.sql\.gz\$' | head -n1" 2>/dev/null || echo "")
  if [ -n "$pick" ] && [ "$pick" != "" ]; then
    echo "$pick"
    return 0
  fi
  
  # Priority 3: sql (plain, skip tiny files)
  pick=$(execc "ls -1 '$WORKDIR_IN_CONTAINER' 2>/dev/null | grep -i '${db}' | grep -i '\.sql\$' | grep -v '\.gz\$' | head -n1" 2>/dev/null || echo "")
  if [ -n "$pick" ] && [ "$pick" != "" ]; then
    # Check file size (must be >= 1MB)
    local size
    size=$(execc "stat -c %s '$WORKDIR_IN_CONTAINER/$pick' 2>/dev/null || echo 0" 2>/dev/null || echo "0")
    if [ "${size:-0}" -ge 1000000 ]; then
      echo "$pick"
      return 0
    fi
  fi
  
  return 1
}

log_selected_source() {
  local db="$1"; local file="$2"
  local size human
  size=$(execc "stat -c %s '$WORKDIR_IN_CONTAINER/$file' 2>/dev/null || echo 0" || echo "0")
  human=$(execc "ls -lh '$WORKDIR_IN_CONTAINER/$file' 2>/dev/null | awk '{print \$5}'" 2>/dev/null || echo "?")
  echo "   • ${db} ⇢ ${file} (${human})"
}

restore_one() {
  local db="$1"
  local file
  if ! file=$(choose_backup_file "$db"); then
    echo "⚠️  No backup file found for ${db}; skipping"
    return 0
  fi
  log_selected_source "$db" "$file"
  local ext="${file##*.}"
  echo "🔄 Restoring ${db}..."
  case "$ext" in
    sql)
      execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '${db}' -f '$WORKDIR_IN_CONTAINER/$file'"
      ;;
    gz)
      execc "gunzip -c '$WORKDIR_IN_CONTAINER/$file' | psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '${db}'"
      ;;
    dump|tar)
      execc "pg_restore -U '$PGUSER' -d '${db}' -c -O -x '$WORKDIR_IN_CONTAINER/$file'"
      ;;
    *)
      echo "⚠️  Unknown extension '$ext' for ${file}; skipping"
      ;;
  esac
  # Post-restore analyze
  execc "psql -v ON_ERROR_STOP=1 -U '$PGUSER' -d '${db}' -c 'ANALYZE VERBOSE;'" || true
  # Revert pragmas
  revert_perf_pragmas "$db"
  echo "✅ ${db} restored"
}

# Temporarily stop dependent services (if docker-compose available)
if command -v docker-compose >/dev/null 2>&1; then
  echo "🛑 Stopping dependent services (backend/keycloak/nginx)..."
  # Stop services gracefully (don't remove containers, just stop them)
  docker-compose -f docker-compose.ssl-complete.yml --env-file .env stop deal-generator deal-setting deal-security keycloak nginx 2>/dev/null || true
  # Give services a moment to stop
  sleep 2
fi

# Debug: List all files in workdir to verify they were copied
echo "🔍 Debug: Listing files in container workdir..."
execc "ls -lh '$WORKDIR_IN_CONTAINER' 2>/dev/null || echo 'ERROR: Workdir not found'" || true

# Summary of selected sources
echo "📄 Selecting best backup source per database:"
for db in "${DBS[@]}"; do
  f=$(choose_backup_file "$db" || true)
  if [ -n "${f:-}" ]; then 
    log_selected_source "$db" "$f"
  else 
    echo "   • ${db} ⇢ none (debug: searching for '*${db}*' in workdir)"
    execc "ls -1 '$WORKDIR_IN_CONTAINER' 2>/dev/null | grep -i '${db}' | head -3" 2>/dev/null || echo "      (no matches found)"
  fi
done

# Restore databases
for db in "${DBS[@]}"; do
  restore_one "$db"
done

# Cleanup
echo "🧹 Cleaning up temporary files..."
execc "rm -rf '$WORKDIR_IN_CONTAINER'"

# Restart services
if command -v docker-compose >/dev/null 2>&1; then
  echo "🚀 Restarting services..."
  # Use restart instead of stop/up to avoid container name conflicts
  # This will only restart the specified services, not recreate containers
  docker-compose -f docker-compose.ssl-complete.yml --env-file .env restart keycloak deal-generator deal-setting deal-security nginx 2>/dev/null || {
    # If restart fails (containers not running), start them
    docker-compose -f docker-compose.ssl-complete.yml --env-file .env up -d keycloak deal-generator deal-setting deal-security nginx 2>/dev/null || true
  }
fi

echo "🎉 Restore completed successfully."
