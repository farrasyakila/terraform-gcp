terraform {
  required_version = "~> v1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = "~> 5.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }

  backend "gcs" {
    bucket = "farra"
    prefix = "learn-with-farra.firewall-farra"
  }
}

locals {
  project = "learn-with-farra"
  region  = "asia-southeast2"
}

provider "google" {
  project = local.project
  region  = local.region
}


resource "google_compute_firewall" "farra-firewall" {
  project     = "learn-with-farra"
  name        = "api"
  network     = "vpc-farra"
  priority    = 1000
  direction   = "INGRESS"
  description = "allow port 8080"

  allow {
    protocol  = "tcp"
    ports     = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
#   target_tags = ["airflow-prod"]
}