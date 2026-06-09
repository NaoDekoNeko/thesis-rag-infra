variable "project_id" {
  type = string
}

variable "docsite_repos" {
  type = list(string)
}

variable "github_org" {
  type = string
}

variable "db_instance_id" {
  description = "ID de la instancia Cloud SQL (para IAM binding de Cloud SQL Client)"
  type        = string
}
