variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región GCP para todos los recursos"
  type        = string
  default     = "us-central1"
}

variable "microservice_image" {
  description = "Imagen Docker del microservicio NestJS (e.g. gcr.io/PROJECT/thesis-rag-microservice:latest)"
  type        = string
}

variable "gemini_api_key" {
  description = "API key de Gemini para embeddings"
  type        = string
  sensitive   = true
}

variable "docsite_repos" {
  description = "Lista de repos de docsite para crear buckets GCS y SAs de CI/CD"
  type        = list(string)
  default     = ["thesis-doc-test-1", "thesis-doc-test-2"]
}

variable "github_org" {
  description = "Organización o usuario de GitHub (para WIF assertion)"
  type        = string
  default     = "NaoDekoNeko"
}

variable "microservice_domain" {
  description = "Subdominio para el microservicio RAG (e.g. api.naodeko.site)"
  type        = string
  default     = "api.naodeko.site"
}

variable "site_domains" {
  description = "Map de site_name => subdominio completo"
  type        = map(string)
  default     = {
    "thesis-doc-test-1" = "platform-eng.naodeko.site"
    "thesis-doc-test-2" = "software-arch.naodeko.site"
  }
}
