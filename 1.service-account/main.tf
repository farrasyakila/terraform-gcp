terraform {
    #versi terraform
    required_version = "~> v1.6.0" 

    #versi provider
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "6.8.0"
        }
    }

    #simpan state di bucket
    backend "gcs" {
    bucket = "farra"
    prefix = "learn-with-farra-0.vpc" #nama direktori di storage nya
    }
}

#env yg disimpan di local
locals {
  project = "learn-with-farra"
  region = "asia-southeast2"
}

#define lokal variable. project dan region sudah fix selalu ada
provider "google" {
  project = local.project
  region = local.region
}

#service account
resource "google_service_account" "farra_service_account" {
  account_id   = "farra-service-acc"
  display_name = "farra service acc"
  disabled = false
}

output "email_farra_sa" {
    value = google_service_account.farra_service_account.email
}

#service account
resource "google_service_account" "github-action" {
  account_id   = "github-action"
  display_name = "github-action"
  disabled = false
}