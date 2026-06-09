output "microservice_url" {
  description = "URL pública del microservicio en Cloud Run"
  value       = module.cloud_run.url
}

output "db_connection_name" {
  description = "Cloud SQL connection name para Cloud Run annotation"
  value       = module.cloud_sql.connection_name
}

output "db_password" {
  description = "Password de PostgreSQL (sensitive)"
  value       = module.cloud_sql.db_password
  sensitive   = true
}

output "docsite_bucket_names" {
  description = "Nombres de buckets GCS de cada docsite"
  value       = { for k, v in module.gcs_sites : k => v.bucket_name }
}

output "microservice_sa_email" {
  description = "SA del microservicio Cloud Run"
  value       = module.iam.microservice_sa_email
}

output "docsite_ci_sa_emails" {
  description = "SAs de CI/CD de docsites (key = repo name)"
  value       = module.iam.docsite_ci_sa_emails
}
