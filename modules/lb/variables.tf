variable "project_id" {
  type = string
}

variable "region" {
  description = "Región donde corre Cloud Run"
  type        = string
}

variable "sites" {
  description = "Map of site_name => bucket_name"
  type        = map(string)
}

variable "domains" {
  description = "Map of site_name => subdomain (e.g. platform-eng.naodeko.site)"
  type        = map(string)
}

variable "microservice_name" {
  description = "Nombre del servicio Cloud Run del microservicio RAG"
  type        = string
}

variable "microservice_domain" {
  description = "Subdominio del microservicio (e.g. api.naodeko.site)"
  type        = string
}
