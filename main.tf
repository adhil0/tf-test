## Kubernetes and Helm Configuration


# Left blank to read in config file from default location (~/.kube/config)
# Use config_path = "${file("${path.cwd}/config")}" to pass in a local config
provider "kubernetes" {
  load_config_file       = false

  # Used to connect to the cluster
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}


# Gives your account permissions to perform all administrative actions needed
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

  # Must create a binding on unique ID of SA too
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "data.google_service_account.terraform.unique_id"
  }
  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
}


# Manually create a namespace since we are using Helm 3
resource "kubernetes_namespace" "jhub" {
  metadata {
    name = var.namespace
  }

  # Dependency to ensure that cluster exists when trying to create or destroy namespace
  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
}


provider "helm" {
  # Leave kubernetes block blank to read in config file from default location (~/.kube/config)
  kubernetes {
    load_config_file       = false

  # Used to connect to the cluster
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
  }
}
# Install Helm Chart configured by config.yaml
resource "helm_release" "jhub" {
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart/" 
  chart      = "jupyterhub"
  namespace  = kubernetes_namespace.jhub.metadata[0].name
  version    = var.helm_version

  # Passes config.yaml to helm
  values     = [
    "${file("${path.cwd}/${var.helm_config_name}")}" # change variable to entire path
  ]

  set_sensitive {
    name  = "proxy.secretToken"
    value = var.proxy_secret_token
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

  set_sensitive [
    name  = "proxy.service.loadBalancerIP"
    value = var.IP
  ]
  # Prints IP 
  provisioner "local-exec" {
    command = "kubectl get services -n jhub"
  }
}
