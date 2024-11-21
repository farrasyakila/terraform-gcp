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
    prefix = "learn-with-farra.cloudsql-farra"
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

# resource "google_sql_database_instance" "prod-1" {
#   name                = "prod-1"
#   database_version    = "MYSQL_8_0_31"
#   deletion_protection = "false"
#   settings {
#     tier              = "db-custom-1-3840"
#     disk_type         = "PD_HDD"
#     availability_type = "ZONAL"
#     deletion_protection_enabled = "false"
#     backup_configuration {
#       start_time                     = "02:00"
#       binary_log_enabled             = true
#       enabled                        = true
#       location                       = "asia"
#       backup_retention_settings {
#         retained_backups = 7
#         retention_unit   = "COUNT"
#       }
#       transaction_log_retention_days    = 7
#     }

#     ip_configuration {
#       ipv4_enabled     = true
#       private_network  = "projects/learn-with-farra/global/networks/vpc-farra"
#       authorized_networks {
#         name  = "all"
#         value = "0.0.0.0/0"
#       }
#     }
#     pricing_plan = "PER_USE"
#     disk_autoresize = true
#     disk_autoresize_limit = "0"
#     maintenance_window {
#       day = 1
#       hour = 1
#       update_track = "canary"
#     }
#   }
# }