
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("${var.json_credentials}") 
  zone        = var.zone
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  # name     = "${var.project_id}-gke"
  name     = "fall-2020-ling226"  # name must start with a letter
  location = var.zone

  remove_default_node_pool = false
  initial_node_count       = var.default_node_count
  node_config {
    machine_type = var.default_machine_type 
    disk_type    = var.default_storage_type
  }
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = true  # Might need to change to false
    }
  }
  # Connect to cluster for future Kubectl commands
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials fall-2020-ling226 --zone ${var.zone} --project ${var.project_id}"
  }
}
  # cluster_autoscaling {
  #   enabled = true
  #   resource_limits {
  #        resource_type = "cpu"
  #        maximum = 10
  #     }
  #   resource_limits {
  #        resource_type = "memory"
  #        maximum = 96
  #     }
  # }


# Separately Managed Node Pool for Users
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.user_pool_num_nodes
  autoscaling {
    min_node_count = var.user_pool_min_nodes
    max_node_count = var.user_pool_max_nodes
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      # env = var.project_id
      "hub.jupyter.org/node-purpose"="user"
    }

    # preemptible  = true
    machine_type = var.user_pool_machine_type
    tags         = ["gke-node", "fall-2020-ling226"]
    metadata     = {
      disable-legacy-endpoints = "true"
    }
    disk_type    = var.user_pool_disk_type

    taint {
      key = "hub.jupyter.org_dedicated"
      value = "user"
      effect = "NO_SCHEDULE"
    }
  }
}

# The two data blocks are used to connect to the cluster

# Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {
}

data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name
  location = var.zone
}

data "kubernetes_service" "example" {
  metadata {
    name = "proxy-public"
    namespace = helm_release.jhub.metadata[0].namespace
  }
}