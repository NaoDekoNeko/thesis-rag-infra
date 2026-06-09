output "microservice_sa_email" {
  value = google_service_account.microservice.email
}

output "microservice_ci_sa_email" {
  value = google_service_account.microservice_ci.email
}

output "docsite_ci_sa_emails" {
  value = { for k, v in google_service_account.docsite_ci : k => v.email }
}

output "artifact_registry_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.thesis_rag.repository_id}"
}
