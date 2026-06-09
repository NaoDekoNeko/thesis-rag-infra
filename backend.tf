terraform {
  backend "gcs" {
    # bucket se pasa en CI con: -backend-config="bucket=$TF_STATE_BUCKET"
    # o localmente: terraform init -backend-config="bucket=<nombre-bucket>"
    prefix = "thesis-rag/state"
  }
}
