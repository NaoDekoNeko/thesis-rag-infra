#!/usr/bin/env bash
# Configura todos los GitHub Secrets de los 4 repos del proyecto.
# Lo corre automáticamente el job propagate-secrets de terraform.yml
# después de cada apply. Solo hace falta correrlo a mano para debug
# puntual; en ese caso requiere gh autenticado (gh auth login).
set -euo pipefail

ORG="NaoDekoNeko"
WIF_PROVIDER="projects/776539408797/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
PROJECT_ID="thesis-rag-poc"
REGION="us-central1"

# ── Pedir valores que no están en Terraform ───────────────────────────────────
# ponytail: si ya viene por env (ej. corrida en CI), no preguntar
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
if [ -z "$GEMINI_API_KEY" ]; then
  read -rsp "GEMINI_API_KEY: " GEMINI_API_KEY; echo
fi

# ── Leer outputs de Terraform ─────────────────────────────────────────────────
TF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
pushd "$TF_DIR" > /dev/null

TF_STATE_BUCKET="${PROJECT_ID}-tfstate"
MICROSERVICE_CI_SA=$(terraform output -raw microservice_ci_sa_email 2>/dev/null)
DOC1_SA=$(terraform output -json docsite_ci_sa_emails 2>/dev/null | jq -r '.["thesis-doc-test-1"]')
DOC2_SA=$(terraform output -json docsite_ci_sa_emails 2>/dev/null | jq -r '.["thesis-doc-test-2"]')
DOC1_BUCKET=$(terraform output -json docsite_bucket_names 2>/dev/null | jq -r '.["thesis-doc-test-1"]')
DOC2_BUCKET=$(terraform output -json docsite_bucket_names 2>/dev/null | jq -r '.["thesis-doc-test-2"]')
DB_INSTANCE=$(terraform output -raw db_connection_name 2>/dev/null)
DB_PASSWORD=$(terraform output -raw db_password 2>/dev/null)
MICROSERVICE_URL="https://api.naodeko.site"

popd > /dev/null

set_secret() {
  local repo="$1" name="$2" value="$3"
  echo "  $repo → $name"
  echo -n "$value" | gh secret set "$name" --repo "${ORG}/${repo}"
}

# ── thesis-rag-infra ──────────────────────────────────────────────────────────
echo "==> thesis-rag-infra"
set_secret thesis-rag-infra GCP_PROJECT_ID        "$PROJECT_ID"
set_secret thesis-rag-infra GCP_REGION            "$REGION"
set_secret thesis-rag-infra TF_STATE_BUCKET        "$TF_STATE_BUCKET"
set_secret thesis-rag-infra WIF_PROVIDER           "$WIF_PROVIDER"
set_secret thesis-rag-infra WIF_SERVICE_ACCOUNT    "terraform-deployer@${PROJECT_ID}.iam.gserviceaccount.com"
set_secret thesis-rag-infra GEMINI_API_KEY         "$GEMINI_API_KEY"

# ── thesis-rag-microservice ───────────────────────────────────────────────────
echo "==> thesis-rag-microservice"
set_secret thesis-rag-microservice GCP_PROJECT_ID      "$PROJECT_ID"
set_secret thesis-rag-microservice GCP_REGION          "$REGION"
set_secret thesis-rag-microservice WIF_PROVIDER        "$WIF_PROVIDER"
set_secret thesis-rag-microservice WIF_SERVICE_ACCOUNT "$MICROSERVICE_CI_SA"

# ── thesis-doc-test-1 ─────────────────────────────────────────────────────────
echo "==> thesis-doc-test-1"
set_secret thesis-doc-test-1 GCP_PROJECT_ID      "$PROJECT_ID"
set_secret thesis-doc-test-1 GCP_REGION          "$REGION"
set_secret thesis-doc-test-1 WIF_PROVIDER        "$WIF_PROVIDER"
set_secret thesis-doc-test-1 WIF_SERVICE_ACCOUNT "$DOC1_SA"
set_secret thesis-doc-test-1 GCS_BUCKET          "$DOC1_BUCKET"
set_secret thesis-doc-test-1 GEMINI_API_KEY      "$GEMINI_API_KEY"
set_secret thesis-doc-test-1 DB_INSTANCE         "$DB_INSTANCE"
set_secret thesis-doc-test-1 DB_NAME             "ragdb"
set_secret thesis-doc-test-1 DB_USER             "raguser"
set_secret thesis-doc-test-1 DB_PASSWORD         "$DB_PASSWORD"
set_secret thesis-doc-test-1 MICROSERVICE_URL    "$MICROSERVICE_URL"

# ── thesis-doc-test-2 ─────────────────────────────────────────────────────────
echo "==> thesis-doc-test-2"
set_secret thesis-doc-test-2 GCP_PROJECT_ID      "$PROJECT_ID"
set_secret thesis-doc-test-2 GCP_REGION          "$REGION"
set_secret thesis-doc-test-2 WIF_PROVIDER        "$WIF_PROVIDER"
set_secret thesis-doc-test-2 WIF_SERVICE_ACCOUNT "$DOC2_SA"
set_secret thesis-doc-test-2 GCS_BUCKET          "$DOC2_BUCKET"
set_secret thesis-doc-test-2 GEMINI_API_KEY      "$GEMINI_API_KEY"
set_secret thesis-doc-test-2 DB_INSTANCE         "$DB_INSTANCE"
set_secret thesis-doc-test-2 DB_NAME             "ragdb"
set_secret thesis-doc-test-2 DB_USER             "raguser"
set_secret thesis-doc-test-2 DB_PASSWORD         "$DB_PASSWORD"
set_secret thesis-doc-test-2 MICROSERVICE_URL    "$MICROSERVICE_URL"

echo ""
echo "Secretos configurados en los 4 repos."
