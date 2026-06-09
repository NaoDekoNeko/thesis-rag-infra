variable "project_id" {
  type = string
}

variable "sites" {
  description = "Map of site_name => bucket_name"
  type        = map(string)
}
