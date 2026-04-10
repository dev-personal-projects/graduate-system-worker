#!/usr/bin/env bash
# Upload GradTrack API secrets to Azure Key Vault
# Usage: ./scripts/upload-secrets.sh
# Requires: az CLI logged in with access to gradtrack-api-kv
set -euo pipefail

VAULT="gradtrack-api-kv"

# ── Helpers ──────────────────────────────────────────────────────────────────
set_secret() {
  local name="$1" value="$2"
  if [[ -z "$value" ]]; then
    echo "  SKIP  $name  (empty — set the variable at the top of this script)"
    return
  fi
  az keyvault secret set --vault-name "$VAULT" --name "$name" --value "$value" --output none
  echo "  OK    $name"
}

echo "Uploading secrets to Key Vault: $VAULT"
echo "────────────────────────────────────────────────────────────────────────"

# ── Fill in your values below before running ─────────────────────────────────

# Supabase
SUPABASE_URL=""
SUPABASE_SERVICE_ROLE_KEY=""

# Committee auth — random 32+ char string, e.g.: openssl rand -base64 32
COMMITTEE_AUTH_SESSION_SECRET=""

# Committee PIN (optional — defaults to 123456 if omitted)
COMMITTEE_PIN=""

# CORS — deployed frontend URL, e.g. https://gradtrack.must.ac.ke
CORS_ALLOWED_ORIGINS_0=""

# Azure OpenAI (optional — AI report generation)
AZURE_AI_ENDPOINT=""
AZURE_AI_API_KEY=""
AZURE_AI_DEPLOYMENT_NAME=""

# ── Upload ────────────────────────────────────────────────────────────────────
set_secret "Supabase--Url"                        "$SUPABASE_URL"
set_secret "Supabase--ServiceRoleKey"             "$SUPABASE_SERVICE_ROLE_KEY"
set_secret "CommitteeAuth--SessionSecret"         "$COMMITTEE_AUTH_SESSION_SECRET"
set_secret "CommitteePin"                         "$COMMITTEE_PIN"
set_secret "Cors--AllowedOrigins--0"              "$CORS_ALLOWED_ORIGINS_0"
set_secret "AzureAI--Endpoint"                    "$AZURE_AI_ENDPOINT"
set_secret "AzureAI--ApiKey"                      "$AZURE_AI_API_KEY"
set_secret "AzureAI--DeploymentName"              "$AZURE_AI_DEPLOYMENT_NAME"

echo "────────────────────────────────────────────────────────────────────────"
echo "Done. Verify: az keyvault secret list --vault-name $VAULT -o table"
