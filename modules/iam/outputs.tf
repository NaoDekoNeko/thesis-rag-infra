output "microservice_sa_email" {
  value = google_service_account.microservice.email
}

output "docsite_ci_sa_emails" {
  value = { for k, v in google_service_account.docsite_ci : k => v.email }
}
