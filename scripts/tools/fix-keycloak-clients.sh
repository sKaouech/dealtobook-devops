#!/bin/bash

echo "🔧 Correction des clients Keycloak..."
echo ""

# Configuration
KEYCLOAK_URL="https://keycloak-dev.dealtobook.com"
ADMIN_USER="admin"
ADMIN_PASSWORD="DealToBook2024AdminSecure!"
REALM="dealtobook"

# Clients à configurer
declare -A CLIENTS
CLIENTS["dealsecurity"]="dealtobook-secret"
CLIENTS["dealdealgen"]="dealtobook-secret"  
CLIENTS["dealsetting"]="dealtobook-secret"
CLIENTS["dealweb"]="dealtobook-secret"
CLIENTS["dealtobook-app"]="dealtobook-secret"

echo "=== Obtention du token admin ==="
ADMIN_TOKEN=$(curl -k -s -X POST \
  "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASSWORD" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | \
  grep -o '"access_token":"[^"]*"' | \
  cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Impossible d'obtenir le token admin"
    exit 1
fi

echo "✅ Token admin obtenu"
echo ""

echo "=== Vérification et création des clients ==="
for CLIENT_ID in "${!CLIENTS[@]}"; do
    CLIENT_SECRET="${CLIENTS[$CLIENT_ID]}"
    echo "--- Client: $CLIENT_ID ---"
    
    # Vérifier si le client existe
    CLIENT_EXISTS=$(curl -k -s -X GET \
      "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=$CLIENT_ID" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" | \
      grep -c "\"clientId\":\"$CLIENT_ID\"")
    
    if [ "$CLIENT_EXISTS" -eq 0 ]; then
        echo "⚠️  Client $CLIENT_ID n'existe pas, création..."
        
        # Créer le client
        CREATE_RESPONSE=$(curl -k -s -w "%{http_code}" -X POST \
          "$KEYCLOAK_URL/admin/realms/$REALM/clients" \
          -H "Authorization: Bearer $ADMIN_TOKEN" \
          -H "Content-Type: application/json" \
          -d "{
            \"clientId\": \"$CLIENT_ID\",
            \"enabled\": true,
            \"clientAuthenticatorType\": \"client-secret\",
            \"secret\": \"$CLIENT_SECRET\",
            \"serviceAccountsEnabled\": true,
            \"standardFlowEnabled\": true,
            \"implicitFlowEnabled\": false,
            \"directAccessGrantsEnabled\": true,
            \"publicClient\": false,
            \"protocol\": \"openid-connect\",
            \"attributes\": {
              \"saml.assertion.signature\": \"false\",
              \"saml.force.post.binding\": \"false\",
              \"saml.multivalued.roles\": \"false\",
              \"saml.encrypt\": \"false\",
              \"saml.server.signature\": \"false\",
              \"saml.server.signature.keyinfo.ext\": \"false\",
              \"exclude.session.state.from.auth.response\": \"false\",
              \"saml_force_name_id_format\": \"false\",
              \"saml.client.signature\": \"false\",
              \"tls.client.certificate.bound.access.tokens\": \"false\",
              \"saml.authnstatement\": \"false\",
              \"display.on.consent.screen\": \"false\",
              \"saml.onetimeuse.condition\": \"false\"
            },
            \"authenticationFlowBindingOverrides\": {},
            \"fullScopeAllowed\": true,
            \"nodeReRegistrationTimeout\": -1,
            \"defaultClientScopes\": [
              \"web-origins\",
              \"role_list\",
              \"profile\",
              \"roles\",
              \"email\"
            ],
            \"optionalClientScopes\": [
              \"address\",
              \"phone\",
              \"offline_access\",
              \"microprofile-jwt\"
            ]
          }")
        
        HTTP_CODE="${CREATE_RESPONSE: -3}"
        if [ "$HTTP_CODE" = "201" ]; then
            echo "✅ Client $CLIENT_ID créé avec succès"
        else
            echo "❌ Erreur lors de la création du client $CLIENT_ID (HTTP: $HTTP_CODE)"
        fi
    else
        echo "✅ Client $CLIENT_ID existe déjà"
        
        # Obtenir l'ID interne du client
        CLIENT_UUID=$(curl -k -s -X GET \
          "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=$CLIENT_ID" \
          -H "Authorization: Bearer $ADMIN_TOKEN" \
          -H "Content-Type: application/json" | \
          grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ -n "$CLIENT_UUID" ]; then
            # Mettre à jour le secret
            UPDATE_RESPONSE=$(curl -k -s -w "%{http_code}" -X PUT \
              "$KEYCLOAK_URL/admin/realms/$REALM/clients/$CLIENT_UUID" \
              -H "Authorization: Bearer $ADMIN_TOKEN" \
              -H "Content-Type: application/json" \
              -d "{
                \"clientId\": \"$CLIENT_ID\",
                \"enabled\": true,
                \"clientAuthenticatorType\": \"client-secret\",
                \"secret\": \"$CLIENT_SECRET\",
                \"serviceAccountsEnabled\": true,
                \"standardFlowEnabled\": true,
                \"implicitFlowEnabled\": false,
                \"directAccessGrantsEnabled\": true,
                \"publicClient\": false
              }")
            
            HTTP_CODE="${UPDATE_RESPONSE: -3}"
            if [ "$HTTP_CODE" = "204" ]; then
                echo "✅ Secret du client $CLIENT_ID mis à jour"
            else
                echo "⚠️  Erreur lors de la mise à jour du client $CLIENT_ID (HTTP: $HTTP_CODE)"
            fi
        fi
    fi
    echo ""
done

echo "=== Test des clients créés ==="
for CLIENT_ID in "${!CLIENTS[@]}"; do
    CLIENT_SECRET="${CLIENTS[$CLIENT_ID]}"
    echo "--- Test client: $CLIENT_ID ---"
    
    TOKEN_RESPONSE=$(curl -k -s -w "%{http_code}" -X POST \
      "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials" \
      -d "client_id=$CLIENT_ID" \
      -d "client_secret=$CLIENT_SECRET")
    
    HTTP_CODE="${TOKEN_RESPONSE: -3}"
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Client $CLIENT_ID fonctionne correctement"
    else
        echo "❌ Client $CLIENT_ID a un problème (HTTP: $HTTP_CODE)"
        echo "Response: ${TOKEN_RESPONSE%???}"
    fi
done

echo ""
echo "🎉 Configuration des clients Keycloak terminée !"
echo ""
echo "=== Prochaines étapes ==="
echo "1. Redémarrer les services backend pour recharger les credentials"
echo "2. Vérifier les logs des services"
echo "3. Tester l'authentification frontend"
