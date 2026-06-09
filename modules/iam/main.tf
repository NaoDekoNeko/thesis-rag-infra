resource "google_service_account" "microservice" {
  project      = var.project_id
  account_id   = "thesis-rag-microservice"
  display_name = "Thesis RAG – Cloud Run microservice"
}

resource "google_project_iam_member" "microservice_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.microservice.email}"
}

resource "google_project_iam_member" "microservice_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.microservice.email}"
}

resource "google_service_account" "docsite_ci" {
  for_each = toset(var.docsite_repos)

  project      = var.project_id
  account_id   = "ci-${each.key}"
  display_name = "CI/CD – ${each.key}"
}

resource "google_project_iam_member" "docsite_ci_run_invoker" {
  for_each = toset(var.docsite_repos)

  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.docsite_ci[each.key].email}"
}

resource "google_project_iam_member" "docsite_ci_sql_client" {
  for_each = toset(var.docsite_repos)

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.docsite_ci[each.key].email}"
}

resource "google_project_iam_member" "docsite_ci_lb_admin" {
  for_each = toset(var.docsite_repos)

  project = var.project_id
  role    = "roles/compute.loadBalancerAdmin"
  member  = "serviceAccount:${google_service_account.docsite_ci[each.key].email}"
}

# Permite que el WIF del repo de infra impersone los SAs de docsite CI
# (El WIF pool ya fue creado en bootstrap.sh)
resource "google_service_account_iam_member" "docsite_ci_wif" {
  for_each = toset(var.docsite_repos)

  service_account_id = google_service_account.docsite_ci[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${var.github_org}/${each.key}"
}

# SA para el CI/CD del microservicio (push a Artifact Registry + deploy Cloud Run)
resource "google_service_account" "microservice_ci" {
  project      = var.project_id
  account_id   = "ci-microservice"
  display_name = "CI/CD – thesis-rag-microservice"
}

resource "google_project_iam_member" "microservice_ci_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.microservice_ci.email}"
}

resource "google_project_iam_member" "microservice_ci_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.microservice_ci.email}"
}

resource "google_project_iam_member" "microservice_ci_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.microservice_ci.email}"
}

resource "google_service_account_iam_member" "microservice_ci_wif" {
  service_account_id = google_service_account.microservice_ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${var.github_org}/thesis-rag-microservice"
}

# Artifact Registry repository para las imágenes Docker
resource "google_artifact_registry_repository" "thesis_rag" {
  project       = var.project_id
  location      = var.region
  repository_id = "thesis-rag"
  format        = "DOCKER"
}

data "google_project" "current" {
  project_id = var.project_id
}
