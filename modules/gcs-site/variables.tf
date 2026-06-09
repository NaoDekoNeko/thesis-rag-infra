variable "project_id" {
  type = string
}

variable "site_name" {
  description = "Nombre del repo/site (e.g. thesis-doc-test-1)"
  type        = string
}

variable "ci_sa_email" {
  description = "SA de CI/CD con permisos de escritura en este bucket"
  type        = string
}

variable "location" {
  description = "Región GCS del bucket"
  type        = string
  default     = "us-central1"
}
