output "ip" {
  value = google_compute_global_address.ip.address
}

output "site_urls" {
  value = { for name, domain in var.domains : name => "https://${domain}" }
}
