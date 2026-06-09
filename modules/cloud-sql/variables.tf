variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "db_tier" {
  description = "Tier de Cloud SQL (db-f1-micro para PoC)"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  type    = string
  default = "ragdb"
}

variable "db_user" {
  type    = string
  default = "raguser"
}

variable "postgres_version" {
  type    = string
  default = "POSTGRES_15"
}
