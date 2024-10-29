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
    prefix = "learn-with-farra.vpc-farra" #nama direktori di storage nya
    }
}

#env yg disimpen di local
locals {
  project = "learn-with-farra"
  region = "asia-southeast2"
}

#define lokal variable. project dan region sudah fixx
provider "google" {
  project = local.project
  region = local.region
}

# #vpc
# resource "google_compute_network" "vpc-farra" {
#    name    = "vpc-farra" 
#    auto_create_subnetworks = false
# }

# #subnet
# resource "google_compute_subnetwork" "farra-subnet" {
#     name          = "farra-subnet"
#     network       = google_compute_network.vpc-farra.name
#     ip_cidr_range = "10.232.4.0/24"
#     secondary_ip_range {
#       range_name    = "pods"
#       ip_cidr_range = "10.232.64.0/22" 
#     }
#     secondary_ip_range {
#       range_name    = "services"
#       ip_cidr_range = "10.232.71.0/24"
#     }
# }

# #remote-state
# data "terraform_remote_state" "sa_farra" { #jika data ada di direktori berbeda bisa gunakan remote state untuk ngelink datanya
#   backend = "gcs"
#   config = {
#     bucket = "farra"
#     prefix = "learn-with-farra-0.vpc" #prefix yang ada di service account
#   }
# }

# #vm
# resource "google_compute_instance" "farraa-vm" {
#     name         = "farraa-vm"
#     machine_type = "e2-micro"
#     zone         = "asia-southeast2-b"
#     boot_disk {
#     auto_delete = true
#     mode        = "READ_WRITE"
#     initialize_params {
#         image = "ubuntu-os-cloud/ubuntu-minimal-2204-jammy-v20230907"
#         size  = 10
#         type  = "pd-balanced"
#    }
#  }
#     network_interface {
#         network    = google_compute_network.vpc-farra.name
#         subnetwork = google_compute_subnetwork.farra-subnet.name
#         access_config {}
#  }
#     metadata = {
#         ssh-keys = "farra:${file("farra.pub")}"
#     }

#     service_account {
#         email  = data.terraform_remote_state.sa_farra.outputs.email_farra_sa
#         scopes = ["cloud-platform"]
#   }
# }


#vm test
resource "google_compute_instance" "test-vm" {
    name         = "test-vm"
    machine_type = "e2-micro"
    zone         = "asia-southeast2-b"
    boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"
    initialize_params {
        image = "ubuntu-os-cloud/ubuntu-minimal-2204-jammy-v20230907"
        size  = 10
        type  = "pd-balanced"
   }
 }
    network_interface {
        network    = "vpc-farra"
        subnetwork = "farra-subnet"
        access_config {}
 }
    metadata = {
        ssh-keys = "farra:${file("farra.pub")}"
    }
}