module "iam" {
  source = "./modules/iam"

  project_id     = var.project_id
  region         = var.region
  docsite_repos  = var.docsite_repos
  github_org     = var.github_org
  db_instance_id = module.cloud_sql.instance_id
}

module "cloud_sql" {
  source = "./modules/cloud-sql"

  project_id = var.project_id
  region     = var.region
}

module "cloud_run" {
  source = "./modules/cloud-run"

  project_id            = var.project_id
  region                = var.region
  image                 = var.microservice_image
  service_account       = module.iam.microservice_sa_email
  db_connection_name    = module.cloud_sql.connection_name
  db_name               = module.cloud_sql.db_name
  db_user               = module.cloud_sql.db_user
  db_password           = module.cloud_sql.db_password
  db_superuser_password = module.cloud_sql.db_superuser_password
  gemini_api_key        = var.gemini_api_key
  custom_domain         = var.microservice_domain
}

module "gcs_sites" {
  source   = "./modules/gcs-site"
  for_each = toset(var.docsite_repos)

  project_id  = var.project_id
  site_name   = each.key
  ci_sa_email = module.iam.docsite_ci_sa_emails[each.key]
}

module "lb" {
  source     = "./modules/lb"
  project_id = var.project_id
  sites      = { for k, v in module.gcs_sites : k => v.bucket_name }
  domains    = var.site_domains
}

resource "google_dns_record_set" "docsite" {
  for_each = var.site_domains

  project      = var.project_id
  managed_zone = var.dns_zone_name
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  rrdatas      = [module.lb.ip]
}
