# ── User-facing ───────────────────────────────────────────────────────────────

output "summary" {
  description = "Resumen de los recursos desplegados"
  value       = <<-EOT

    # 🚀 Thesis RAG — Infra desplegada

    ## 🔗 URLs
    | Servicio | URL |
    |----------|-----|
    | 🤖 Microservicio RAG | ${module.cloud_run.url} |
    | 📘 Platform Engineering Docs | ${module.lb.site_urls["thesis-doc-test-1"]} |
    | 📗 Software Architecture Docs | ${module.lb.site_urls["thesis-doc-test-2"]} |

    ## ⚙️ Próximos pasos
    1. Actualizar `docusaurus.config.ts` en ambos repos:
       ```
       url: "http://${module.lb.ip}"
       ```
    2. Configurar GitHub Secrets:
       ```
       bash scripts/set-github-secrets.sh
       ```
  EOT
}

output "lb_ip" {
  description = "IP del Load Balancer — usar en docusaurus.config.ts"
  value       = module.lb.ip
}

output "microservice_url" {
  description = "URL pública del microservicio en Cloud Run"
  value       = module.cloud_run.url
}

# ── Usados por set-github-secrets.sh (no editar) ──────────────────────────────

output "artifact_registry_image_base" {
  value = "${module.iam.artifact_registry_repo}/microservice"
}

output "microservice_ci_sa_email" {
  value = module.iam.microservice_ci_sa_email
}

output "docsite_ci_sa_emails" {
  value = module.iam.docsite_ci_sa_emails
}

output "docsite_bucket_names" {
  value = { for k, v in module.gcs_sites : k => v.bucket_name }
}

output "db_connection_name" {
  value = module.cloud_sql.connection_name
}

output "db_password" {
  value     = module.cloud_sql.db_password
  sensitive = true
}
