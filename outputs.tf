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

output "microservice_ci_sa_email" {
  description = "SA de CI/CD del microservicio (para WIF_SERVICE_ACCOUNT en ese repo)"
  value       = module.iam.microservice_ci_sa_email
}

output "docsite_ci_sa_emails" {
  description = "SAs de CI/CD de docsites (key = repo name)"
  value       = module.iam.docsite_ci_sa_emails
}

output "artifact_registry_image_base" {
  description = "Base URL para imágenes Docker en Artifact Registry"
  value       = "${module.iam.artifact_registry_repo}/microservice"
}

output "lb_ip" {
  description = "IP del Load Balancer HTTP con Cloud CDN"
  value       = module.lb.ip
}

output "docsite_urls" {
  description = "URLs de los docsites vía LB+CDN"
  value       = module.lb.site_urls
}
