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

# Permite que el WIF del repo de infra impersone los SAs de docsite CI
# (El WIF pool ya fue creado en bootstrap.sh)
resource "google_service_account_iam_member" "docsite_ci_wif" {
  for_each = toset(var.docsite_repos)

  service_account_id = google_service_account.docsite_ci[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${var.github_org}/${each.key}"
}

data "google_project" "current" {
  project_id = var.project_id
}
