/**********************
Provider Configuration
***********************/
provider "google" {
  project = var.project_id # create dependency on project google_project.my_project.project_id
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {
  load_config_file = false

  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host                   = module.gke.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

data "google_client_config" "default" {
}
/* CREATE PROJECT
module "project-factory" {
  source                  = "terraform-google-modules/project-factory/google"

  project_id       				= test
  name                    = "test-project"
  org_id                  = 867683236978 #TODO: variabilize
  billing_account         = 01AB5F-7559AA-EBD05A  #TODO: Variabilize
  # credentials_path        = local.credentials_file_path
	activate_apis           = ["compute.googleapis.com", "container.googleapis.com"] #TODO
	auto_create_network     = true
#   activate_api_identities = [{
#     api = "healthcare.googleapis.com"
#     roles = [
#       "roles/healthcare.serviceAgent",
#       "roles/bigquery.jobUser",
#     ]
#   }]
# }
*/
#TODO Do we need this? gke module can create service accounts
/*********************
Create Service Account
**********************/
# module "service_accounts" {
#   source        = "terraform-google-modules/service-accounts/google"
#   project_id    = var.project_id
#   names         = [var.service_account_name]
#   project_roles = formatlist("${var.project_id}=>%s", var.service_account_roles)

#   display_name  = "Single Account"
#   description   = "Single Account Description"
#   generate_keys = true
# }

/***********************************
Create Cluster and Node Pools
************************************/
module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id                        = var.project_id
  name                              = "${var.project_id}-gke" #TODO: Variabilize
  region                            = var.region
  zones                             = [var.zone]
  network                           = "default"
  subnetwork                        = "default"
  ip_range_pods                     = ""
  ip_range_services                 = ""
  create_service_account            = false
  disable_legacy_metadata_endpoints = false
  remove_default_node_pool          = true

  node_pools = [
    {
      name               = "default-pool"
      machine_type       = var.default_machine_type
      initial_node_count = var.default_node_count
    },
    {
      name               = "user-pool"
      machine_type       = var.user_pool_machine_type
      min_count          = var.user_pool_min_nodes
      max_count          = var.user_pool_max_nodes
      initial_node_count = var.user_pool_num_nodes
      auto_upgrade       = true
    },
  ]

  node_pools_labels = {
    user-pool = {
      "hub.jupyter.org/node-purpose" = "user"
    }
  }

  node_pools_taints = {
    user-pool = [
      {
        key    = "hub.jupyter.org_dedicated"
        value  = "user"
        effect = "NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    user-pool = [
      "gke-node",
      "${var.project_id}-gke-1", #TODO: Variabilize
    ]
  }
}

/******************************************
Gives account administrative permissions.
*******************************************/
resource "kubernetes_cluster_role_binding" "terraform-rbac-cluster-admin" {
  metadata {
    name = "cluster-admin-binding-terraform"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "data.google_service_account.terraform.email"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "data.google_service_account.terraform.unique_id"
  }
  depends_on = [
    module.gke
  ]
}

/*******************************
Install JupyterHub Using Helm
********************************/
resource "helm_release" "jhub" {
  name             = "jupyterhub"
  repository       = "https://jupyterhub.github.io/helm-chart/"
  chart            = "jupyterhub"
  namespace        = var.namespace
  version          = var.helm_version
  lint             = true
  create_namespace = true
  values = [<<-EOT
scheduling:
  userScheduler:
    enabled: true
  podPriority:
    enabled: true
  userPlaceholder:
    enabled: true
  userPods:
    nodeAffinity:
      matchNodePurpose: require

cull:
  enabled: true
  timeout: 3600
  every: 300

singleuser:
  cpu:
    limit: 1
    guarantee: 0.5
  memory:
    limit: 1G
    guarantee: 512M
  storage:
    capacity: 2G

auth:
  type: google
  google:
    hostedDomain: [ucsb.edu]
    loginService: "UCSBnetID" 
  admin:
    users:
      - eespinosa
      - adhitya

  EOT
  ]

  set_sensitive {
    name  = "proxy.secretToken"
    value = var.proxy_secret_token
  }

  set {
    name  = "auth.admin.users"
    value = "{${join(",", var.admin)}}"
  }

  set_sensitive {
    name  = "proxy.https.hosts"
    value = "{${join(",", var.proxy_https_hosts)}}"
  }

  set_sensitive {
    name  = "proxy.https.letsencrypt.contactEmail"
    value = var.proxy_https_letsencrypt_contactemail
  }

  set_sensitive {
    name  = "auth.google.clientId"
    value = var.auth_google_client_id
  }

  set_sensitive {
    name  = "auth.google.clientSecret"
    value = var.auth_google_client_secret
  }

  set_sensitive {
    name  = "auth.google.callbackUrl"
    value = var.auth_google_callback_url
  }

  set_sensitive {
    name  = "singleuser.image.name"
    value = var.singleuser_image_name
  }

  set_sensitive {
    name  = "singleuser.image.tag"
    value = var.singleuser_image_tag
  }

  set_sensitive {
    name  = "scheduling.userPlaceholder.replicas"
    value = var.placeholders
  }
}

data "kubernetes_service" "example" {
  metadata {
    name      = "proxy-public"
    namespace = helm_release.jhub.metadata[0].namespace
  }
}

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project_id}"
  }
}