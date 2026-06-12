resource "google_compute_global_address" "ip" {
  project = var.project_id
  name    = "thesis-rag-lb-ip"
}

resource "google_compute_backend_bucket" "site" {
  for_each    = var.sites
  project     = var.project_id
  name        = "thesis-rag-${each.key}-cdn"
  bucket_name = each.value
  enable_cdn  = true
}

# Google-managed SSL cert — free, auto-renew
resource "google_compute_managed_ssl_certificate" "sites" {
  project = var.project_id
  name    = "thesis-rag-ssl"
  managed {
    domains = [for domain in values(var.domains) : "${domain}."]
  }
}

# HTTPS URL map — host-based routing, no url_rewrite
resource "google_compute_url_map" "lb" {
  project         = var.project_id
  name            = "thesis-rag-lb"
  default_service = google_compute_backend_bucket.site[keys(var.sites)[0]].self_link

  dynamic "host_rule" {
    for_each = var.domains
    content {
      hosts        = [host_rule.value]
      path_matcher = host_rule.key
    }
  }

  dynamic "path_matcher" {
    for_each = var.domains
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_bucket.site[path_matcher.key].self_link
    }
  }
}

resource "google_compute_target_https_proxy" "lb" {
  project          = var.project_id
  name             = "thesis-rag-lb-https-proxy"
  url_map          = google_compute_url_map.lb.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.sites.self_link]
}

resource "google_compute_global_forwarding_rule" "lb_https" {
  project    = var.project_id
  name       = "thesis-rag-lb-fwd-https"
  target     = google_compute_target_https_proxy.lb.self_link
  port_range = "443"
  ip_address = google_compute_global_address.ip.address
}

# HTTP → HTTPS redirect
resource "google_compute_url_map" "redirect" {
  project = var.project_id
  name    = "thesis-rag-lb-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "thesis-rag-lb-http-proxy"
  url_map = google_compute_url_map.redirect.self_link
}

resource "google_compute_global_forwarding_rule" "lb_http" {
  project    = var.project_id
  name       = "thesis-rag-lb-fwd-http"
  target     = google_compute_target_http_proxy.redirect.self_link
  port_range = "80"
  ip_address = google_compute_global_address.ip.address
}
