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
    prefix = "learn-with-farra-new-bucket" #nama direktori di storage nya
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

# #Bucket
# resource "google_storage_bucket" "bucket_farra_1" {
#   name          = "farra-1"
#   location      = "asia-southeast2"
#   force_destroy = true
#   uniform_bucket_level_access = true
#   public_access_prevention = "enforced"
# }

# #remote state
# data "terraform_remote_state" "sa_farra" { #jika data ada di direktori berbeda bisa gunakan remote state untuk ngelink datanya
#   backend = "gcs"
#   config = {
#     bucket = "farra"
#     prefix = "learn-with-farra-0.vpc" #prefix yang ada di service account
#   }
# }

# #bucket-member
# resource "google_storage_bucket_iam_member" "bucket-farra-sa" {
#   bucket = google_storage_bucket.bucket_farra_1.name
#   role   = "roles/storage.objectViewer"
#   member = "serviceAccount:${data.terraform_remote_state.sa_farra.outputs.email_farra_sa}"
#}