variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "image" {
  description = "Imagen Docker del microservicio"
  type        = string
}

variable "service_account" {
  description = "Email del SA que ejecutará Cloud Run"
  type        = string
}

variable "db_connection_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "gemini_api_key" {
  type      = string
  sensitive = true
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 3
}
