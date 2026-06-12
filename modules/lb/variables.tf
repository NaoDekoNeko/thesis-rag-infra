variable "project_id" {
  type = string
}

variable "sites" {
  description = "Map of site_name => bucket_name"
  type        = map(string)
}

variable "domains" {
  description = "Map of site_name => subdomain (e.g. platform-eng.naodeko.site)"
  type        = map(string)
}
