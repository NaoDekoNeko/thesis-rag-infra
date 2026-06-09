output "connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "instance_id" {
  value = google_sql_database_instance.main.name
}

output "db_name" {
  value = google_sql_database.main.name
}

output "db_user" {
  value = google_sql_user.main.name
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}
