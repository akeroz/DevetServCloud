# Configuration du provider Google Cloud Platform

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configuration du fournisseur GCP
# Les credentials peuvent être configurés via:
# 1. Variable d'environnement GOOGLE_APPLICATION_CREDENTIALS
# 2. gcloud auth application-default login
provider "google" {
  credentials = file("gcp-service-account.json")
  project = var.project_id
  region  = var.region
  zone    = var.zone
}