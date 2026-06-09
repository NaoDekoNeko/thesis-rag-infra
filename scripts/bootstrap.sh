#!/usr/bin/env bash
# Bootstrap one-time: crea el bucket de estado TF, la SA de Terraform y el WIF para GitHub Actions.
# Ejecutar UNA sola vez con: bash bootstrap.sh
# Requiere: gcloud autenticado con cuenta owner del proyecto.
set -euo pipefail

# ── Configuración ──────────────────────────────────────────────────────────────
PROJECT_ID="${1:?Uso: bash bootstrap.sh <project-id> <github-org> [region]}"
GITHUB_ORG="${2:?}"
REGION="${3:-us-central1}"

TF_STATE_BUCKET="${PROJECT_ID}-tfstate"
TF_SA_NAME="terraform-deployer"
TF_SA_EMAIL="${TF_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
WIF_POOL="github-pool"
WIF_PROVIDER="github-provider"
GITHUB_REPO="thesis-rag-infra"
# ──────────────────────────────────────────────────────────────────────────────

echo ">>> Configurando proyecto: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

echo ">>> Habilitando APIs necesarias..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  secretmanager.googleapis.com \
  sqladmin.googleapis.com \
  run.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com \
  compute.googleapis.com \
  --project="$PROJECT_ID"

echo ">>> Creando bucket de estado Terraform: $TF_STATE_BUCKET"
if ! gcloud storage buckets describe "gs://${TF_STATE_BUCKET}" &>/dev/null; then
  gcloud storage buckets create "gs://${TF_STATE_BUCKET}" \
    --project="$PROJECT_ID" \
    --location="$REGION" \
    --uniform-bucket-level-access
  gcloud storage buckets update "gs://${TF_STATE_BUCKET}" --versioning
else
  echo "    (bucket ya existe, saltando)"
fi

echo ">>> Creando Service Account de Terraform: $TF_SA_NAME"
if ! gcloud iam service-accounts describe "$TF_SA_EMAIL" &>/dev/null; then
  gcloud iam service-accounts create "$TF_SA_NAME" \
    --display-name="Terraform Deployer (CI/CD)" \
    --project="$PROJECT_ID"
else
  echo "    (SA ya existe, saltando)"
fi

echo ">>> Asignando roles a la SA de Terraform..."
for ROLE in \
  roles/editor \
  roles/iam.securityAdmin \
  roles/secretmanager.admin \
  roles/storage.admin; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${TF_SA_EMAIL}" \
    --role="$ROLE" \
    --condition=None \
    --quiet
done

echo ">>> Creando Workload Identity Pool: $WIF_POOL"
if ! gcloud iam workload-identity-pools describe "$WIF_POOL" \
    --location="global" --project="$PROJECT_ID" &>/dev/null; then
  gcloud iam workload-identity-pools create "$WIF_POOL" \
    --location="global" \
    --display-name="GitHub Actions pool" \
    --project="$PROJECT_ID"
else
  echo "    (pool ya existe, saltando)"
fi

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

echo ">>> Creando OIDC provider: $WIF_PROVIDER"
if ! gcloud iam workload-identity-pools providers describe "$WIF_PROVIDER" \
    --workload-identity-pool="$WIF_POOL" \
    --location="global" --project="$PROJECT_ID" &>/dev/null; then
  gcloud iam workload-identity-pools providers create-oidc "$WIF_PROVIDER" \
    --workload-identity-pool="$WIF_POOL" \
    --location="global" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.ref=assertion.ref" \
    --attribute-condition="assertion.repository_owner=='${GITHUB_ORG}'" \
    --project="$PROJECT_ID"
else
  echo "    (provider ya existe, saltando)"
fi

echo ">>> Vinculando SA al WIF para el repo ${GITHUB_ORG}/${GITHUB_REPO}..."
gcloud iam service-accounts add-iam-policy-binding "$TF_SA_EMAIL" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/attribute.repository/${GITHUB_ORG}/${GITHUB_REPO}" \
  --project="$PROJECT_ID"

WIF_PROVIDER_FULL="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/providers/${WIF_PROVIDER}"

echo ""
echo "════════════════════════════════════════════════════════════"
echo " Bootstrap completado. Configura estos GitHub Secrets:"
echo "════════════════════════════════════════════════════════════"
echo " GCP_PROJECT_ID      = ${PROJECT_ID}"
echo " GCP_REGION          = ${REGION}"
echo " TF_STATE_BUCKET     = ${TF_STATE_BUCKET}"
echo " WIF_PROVIDER        = ${WIF_PROVIDER_FULL}"
echo " WIF_SERVICE_ACCOUNT = ${TF_SA_EMAIL}"
echo " MICROSERVICE_IMAGE  = gcr.io/${PROJECT_ID}/thesis-rag-microservice:latest"
echo " GEMINI_API_KEY      = <tu API key de Gemini>"
echo "════════════════════════════════════════════════════════════"
