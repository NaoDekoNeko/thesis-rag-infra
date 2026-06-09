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

resource "google_compute_url_map" "lb" {
  project         = var.project_id
  name            = "thesis-rag-lb"
  default_service = google_compute_backend_bucket.site[keys(var.sites)[0]].self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "sites"
  }

  path_matcher {
    name            = "sites"
    default_service = google_compute_backend_bucket.site[keys(var.sites)[0]].self_link

    dynamic "route_rules" {
      for_each = var.sites
      content {
        priority = index(keys(var.sites), route_rules.key) + 1
        match_rules {
          prefix_match = "/${route_rules.key}/"
        }
        route_action {
          url_rewrite {
            path_prefix_rewrite = "/"
          }
        }
        service = google_compute_backend_bucket.site[route_rules.key].self_link
      }
    }
  }
}

resource "google_compute_target_http_proxy" "lb" {
  project = var.project_id
  name    = "thesis-rag-lb-proxy"
  url_map = google_compute_url_map.lb.self_link
}

resource "google_compute_global_forwarding_rule" "lb" {
  project    = var.project_id
  name       = "thesis-rag-lb-fwd"
  target     = google_compute_target_http_proxy.lb.self_link
  port_range = "80"
  ip_address = google_compute_global_address.ip.address
}
