#!/bin/bash

# Script temporaire pour démarrer deal-security sans Hazelcast

ssh -o StrictHostKeyChecking=no root@148.230.114.13 "cd /opt/dealtobook && docker run -d \
  --name dealtobook-security-backend-fixed \
  --network dealtobook_dealtobook-network \
  -p 8082:8082 \
  -e SPRING_PROFILES_ACTIVE=prod,no-liquibase,no-cache \
  -e SPRING_CACHE_TYPE=none \
  -e JHIPSTER_CACHE_HAZELCAST_ENABLED=false \
  -e SPRING_JPA_PROPERTIES_HIBERNATE_CACHE_USE_SECOND_LEVEL_CACHE=false \
  -e SPRING_JPA_PROPERTIES_HIBERNATE_CACHE_USE_QUERY_CACHE=false \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/keycloak \
  -e SPRING_DATASOURCE_USERNAME=dealtobook \
  -e SPRING_DATASOURCE_PASSWORD=DealToBook2024SecurePassword! \
  -e HAZELCAST_INSTANCE_NAME=hazelcast-deal \
  -e JHIPSTER_SLEEP=10 \
  -e LOGGING_LEVEL_ROOT=INFO \
  -e LOGGING_LEVEL_COM_DEALTOBOOK_SECURITY=INFO \
  -e LOGGING_LEVEL_TECH_JHIPSTER=INFO \
  -e LOGGIN_DEALTOBOOK_SETTING=INFO \
  -e LOGGIN_DEALTOBOOK_GENERATOR=INFO \
  -e LOGGIN_DEALTOBOOK_SECURITY=INFO \
  -e KEYCLOAK_REALM=dealtobook \
  -e KEYCLOAK_REALM_PUBLIC_ID=dealtobook \
  -e KEYCLOAK_AUTH_SERVER_URL=https://keycloak-dev.dealtobook.com \
  -e KEYCLOAK_CLIENT_ID=dealsecurity \
  -e KEYCLOAK_CLIENT_SECRET=PNhfRUeloUNMrHMpRosD4HPVVBwWzbkS \
  -e SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_OIDC_ISSUER_URI=https://keycloak-dev.dealtobook.com/realms/dealtobook \
  -e SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_OIDC_CLIENT_ID=dealtobook-app \
  -e SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_OIDC_CLIENT_SECRET=dealtobook-secret \
  -e MANAGEMENT_PROMETHEUS_METRICS_EXPORT_ENABLED=true \
  -e MANAGEMENT_ZIPKIN_TRACING_ENDPOINT=http://zipkin:9411/api/v2/spans \
  -e MANAGEMENT_TRACING_SAMPLING_PROBABILITY=1.0 \
  -e SERVER.URL.DEALSECURITY=http://deal-security:8082 \
  -e SERVER.URL.DEALSETTING=http://deal-setting:8083 \
  ghcr.io/skaouech/dealsecurity:latest"
