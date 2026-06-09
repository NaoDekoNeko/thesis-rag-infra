resource "google_storage_bucket" "site" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.site_name}"
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "ci_write" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.ci_sa_email}"
}

resource "google_storage_bucket_iam_member" "ci_bucket_reader" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${var.ci_sa_email}"
}
