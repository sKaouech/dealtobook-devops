#!/bin/bash
# Script de test pour deploy-ssl-production-v2.sh

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_SCRIPT="$SCRIPT_DIR/deploy-ssl-production-v2.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

# Run a test
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    ((TESTS_RUN++))
    log_test "Running: $test_name"
    
    if eval "$test_cmd" &> /dev/null; then
        pass "$test_name"
        return 0
    else
        fail "$test_name"
        return 1
    fi
}

# Test suite
main() {
    echo -e "${BLUE}"
    echo "======================================"
    echo "Testing deploy-ssl-production-v2.sh"
    echo "======================================"
    echo -e "${NC}"
    
    # Test 1: Script exists and is executable
    run_test "Script exists" "test -f '$DEPLOY_SCRIPT'"
    run_test "Script is executable" "test -x '$DEPLOY_SCRIPT'"
    
    # Test 2: Script syntax is valid
    run_test "Bash syntax is valid" "bash -n '$DEPLOY_SCRIPT'"
    
    # Test 3: Help command works
    run_test "Help command works" "'$DEPLOY_SCRIPT' help"
    
    # Test 4: Service mapping function
    log_test "Testing service mapping..."
    if grep -q "declare -A SERVICE_MAP" "$DEPLOY_SCRIPT"; then
        pass "Service mapping exists"
    else
        fail "Service mapping missing"
    fi
    
    # Test 5: All required functions exist
    local required_functions=(
        "log"
        "success"
        "error"
        "warning"
        "info"
        "map_service_name"
        "parse_services"
        "should_process_service"
        "get_mapped_services_list"
        "setup_java17"
        "run_remote_cmd"
        "check_prerequisites"
        "login_to_ghcr"
        "check_ssl_certificates"
        "setup_ssl_certificates"
        "build_backend_services"
        "build_frontend_services"
        "deploy_to_hostinger"
        "pull_images_on_hostinger"
        "start_services_on_hostinger"
        "stop_services_on_hostinger"
        "restart_services_on_hostinger"
        "scale_services"
        "exec_in_service"
        "inspect_service"
        "setup_databases"
        "setup_keycloak_realm"
        "health_check"
        "test_ssl_endpoints"
        "show_deployment_summary"
        "show_usage"
        "main"
    )
    
    log_test "Checking required functions..."
    for func in "${required_functions[@]}"; do
        if grep -q "^${func}()" "$DEPLOY_SCRIPT"; then
            pass "Function $func exists"
        else
            fail "Function $func missing"
        fi
    done
    
    # Test 6: Environment variables are used correctly
    log_test "Checking environment variables..."
    local required_vars=(
        "GITHUB_USERNAME"
        "REGISTRY"
        "CR_PAT"
        "CUSTOM_TAG"
        "DEPLOY_ENV"
        "DB_READY_TIMEOUT"
        "KEYCLOAK_READY_TIMEOUT"
        "SERVICE_STABILIZATION_TIMEOUT"
    )
    
    for var in "${required_vars[@]}"; do
        if grep -q "$var" "$DEPLOY_SCRIPT"; then
            pass "Variable $var is used"
        else
            fail "Variable $var not found"
        fi
    done
    
    # Test 7: Check for common bash pitfalls
    log_test "Checking for common issues..."
    
    if grep -q "set -euo pipefail" "$DEPLOY_SCRIPT"; then
        pass "Strict error handling enabled"
    else
        fail "Strict error handling missing"
    fi
    
    # Test 8: No hardcoded secrets
    if ! grep -E "(ghp_[a-zA-Z0-9]{36}|password.*=.*['\"])" "$DEPLOY_SCRIPT" | grep -v "KEYCLOAK_ADMIN_PASSWORD"; then
        pass "No hardcoded secrets found"
    else
        fail "Potential hardcoded secrets detected"
    fi
    
    # Test 9: All commands are documented in help
    log_test "Checking command documentation..."
    local commands=(
        "build"
        "build-only"
        "deploy"
        "deploy-only"
        "update"
        "redeploy"
        "start"
        "stop"
        "restart"
        "down"
        "pull"
        "scale"
        "exec"
        "inspect"
        "logs"
        "ps"
        "status"
        "health"
        "test-ssl"
        "ssl-setup"
        "config"
    )
    
    for cmd in "${commands[@]}"; do
        if grep -q "\"$cmd\")" "$DEPLOY_SCRIPT"; then
            pass "Command '$cmd' implemented"
        else
            fail "Command '$cmd' not implemented"
        fi
    done
    
    # Test 10: Check file size (should be reasonable)
    local file_size=$(wc -l < "$DEPLOY_SCRIPT")
    if [ "$file_size" -lt 2000 ]; then
        pass "Script size is reasonable ($file_size lines)"
    else
        fail "Script is too large ($file_size lines)"
    fi
    
    # Summary
    echo ""
    echo -e "${BLUE}======================================"
    echo "Test Summary"
    echo "======================================${NC}"
    echo -e "Total tests run:    ${TESTS_RUN}"
    echo -e "Tests passed:       ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests failed:       ${RED}${TESTS_FAILED}${NC}"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}❌ Some tests failed${NC}"
        return 1
    fi
}

# Run tests
main "$@"

