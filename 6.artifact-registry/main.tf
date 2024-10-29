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
    prefix = "learn-with-farra.registry-farra"
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

resource "google_artifact_registry_repository" "docker-images" {
  cleanup_policy_dry_run = true
  location      = "asia-southeast2"
  repository_id = "docker-images"
  format        = "DOCKER"
  docker_config {
    immutable_tags = false 
  }
}