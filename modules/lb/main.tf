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

# Serverless NEG → Cloud Run microservice
resource "google_compute_region_network_endpoint_group" "microservice" {
  project               = var.project_id
  name                  = "thesis-rag-microservice-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.microservice_name
  }
}

resource "google_compute_backend_service" "microservice" {
  project  = var.project_id
  name     = "thesis-rag-microservice-backend"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.microservice.id
  }
}

# SSL cert para docsites — cert separado para no reprovisionar si cambia api
resource "google_compute_managed_ssl_certificate" "sites" {
  project = var.project_id
  name    = "thesis-rag-ssl"
  managed {
    domains = [for domain in values(var.domains) : "${domain}."]
  }
}

# SSL cert para el microservicio
resource "google_compute_managed_ssl_certificate" "api" {
  project = var.project_id
  name    = "thesis-rag-api-ssl"
  managed {
    domains = ["${var.microservice_domain}."]
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

  host_rule {
    hosts        = [var.microservice_domain]
    path_matcher = "microservice"
  }

  dynamic "path_matcher" {
    for_each = var.domains
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_bucket.site[path_matcher.key].self_link
    }
  }

  path_matcher {
    name            = "microservice"
    default_service = google_compute_backend_service.microservice.self_link
  }
}

resource "google_compute_target_https_proxy" "lb" {
  project = var.project_id
  name    = "thesis-rag-lb-https-proxy"
  url_map = google_compute_url_map.lb.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.sites.self_link,
    google_compute_managed_ssl_certificate.api.self_link,
  ]
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
