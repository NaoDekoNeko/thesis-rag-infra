resource "random_password" "db" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "main" {
  project          = var.project_id
  name             = "thesis-rag-pg"
  database_version = var.postgres_version
  region           = var.region

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      # IP pública con autorización controlada por Cloud SQL Auth Proxy (Cloud Run annotation)
      ipv4_enabled = true
    }

  }

  deletion_protection = false
}

resource "google_sql_database" "main" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_name
}

resource "google_sql_user" "main" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_user
  password = random_password.db.result
}

resource "random_password" "postgres" {
  length  = 24
  special = false
}

resource "google_sql_user" "postgres" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = "postgres"
  password = random_password.postgres.result
}
