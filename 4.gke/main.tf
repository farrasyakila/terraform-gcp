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
    prefix = "learn-with-farra.gke-farra"
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

#vpc
resource "google_compute_network" "vpc-farra" {
   name    = "vpc-farra" 
   auto_create_subnetworks = false
}

#subnet
resource "google_compute_subnetwork" "farra-subnet" {
    name          = "farra-subnet"
    network       = google_compute_network.vpc-farra.name
    ip_cidr_range = "10.232.4.0/24"
    secondary_ip_range {
      range_name    = "pods"
      ip_cidr_range = "10.232.64.0/22" 
    }
    secondary_ip_range {
      range_name    = "services"
      ip_cidr_range = "10.232.71.0/24"
    }
}


resource "google_service_account" "gke-node" {
  account_id   = "gke-node"
  display_name = "gke-node"
  description  = "used by gke node"
}

resource "google_project_iam_member" "gke-node" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/container.nodeServiceAccount",
  ])

  project = local.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke-node.email}"
}

resource "google_project_service" "container" {
  project            = local.project
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_cluster" "cluster" {
  depends_on = [google_project_service.container, google_compute_subnetwork.farra-subnet]
  deletion_protection = false
  name = "default"
  


  # networking

  location   = local.region
  network    = "vpc-farra"
  subnetwork = "farra-subnet"
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods" 
    services_secondary_range_name = "services" 
  }
  default_snat_status {
    disabled = true
  }

  # gke feature

  enable_l4_ilb_subsetting    = true
  enable_intranode_visibility = true
  datapath_provider           = "ADVANCED_DATAPATH"
  default_max_pods_per_node   = 32
  workload_identity_config {
    workload_pool = "${local.project}.svc.id.goog"
  }
  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    # we don't use auto create of node pool, we manage our own node pools
    enabled = false
  }
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = "CLUSTER_SCOPE"
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
  node_pool_defaults {
    node_config_defaults {
      gcfs_config {
        enabled = true
      }
    }
  }
  addons_config {
    dns_cache_config {
      enabled = true
    }
  }


  # cluster upgrade

  release_channel {
    channel = "REGULAR"
  }
  maintenance_policy {
    recurring_window {
      recurrence = "FREQ=DAILY"
      start_time = "2023-01-01T18:00:00Z"
      end_time   = "2023-01-01T22:00:00Z"
    }
  }


  # initial nodes

  initial_node_count       = 2
  remove_default_node_pool = true
  node_config {
    disk_size_gb = 10
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }


  lifecycle {
    # as we using remove_default_node_pool
    # the node_config will be invalid after cluster creation
    ignore_changes = [node_config]
  }
}

locals {
  pools = [
    "e2-standard-2"
  ]
}

resource "google_container_node_pool" "pool" {
  for_each = {
    for p in local.pools : "${p}" => { machine_type = p }
  }

  name     = each.key
  cluster  = google_container_cluster.cluster.name
  location = google_container_cluster.cluster.location

  autoscaling {
    total_min_node_count = 0
    total_max_node_count = 25
  }

  node_config {
    machine_type    = each.value.machine_type
    service_account = google_service_account.gke-node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    disk_type       = "pd-standard"
    gvnic {
      enabled = true
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}