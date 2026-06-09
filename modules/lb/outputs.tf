output "ip" {
  value = google_compute_global_address.ip.address
}

output "url" {
  value = "http://${google_compute_global_address.ip.address}"
}

output "site_urls" {
  value = { for name in keys(var.sites) : name => "http://${google_compute_global_address.ip.address}/${name}/" }
}
