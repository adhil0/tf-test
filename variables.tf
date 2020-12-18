/**********************
Provider Configuration
***********************/
variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}

/**********************
Create Service Account
***********************/
variable "service_account_name" {
  description = "name of service account"
}

variable "service_account_roles" {
  type        = list(string)
  description = "Roles assigned to service account"
}

/***********************************
Create Cluster and Node Pools
************************************/
variable "user_pool_num_nodes" {
  default     = 0
  description = "number of gke nodes"
}

variable "user_pool_min_nodes" {
  default     = 0
  description = "minimum number of user pool nodes in autoscaling"
}

variable "user_pool_max_nodes" {
  default     = 3
  description = "maximum number of user pool nodes in autoscaling"
}

variable "user_pool_machine_type" {
  default     = "n1-standard-2"
  description = "machine type of user node pool"
}

variable "user_pool_disk_type" {
  default     = "pd-ssd"
  description = "disk type of user node pool"
}

variable "default_node_count" {
  default     = "2"
  description = "number of nodes for the default node pool"
}

variable "default_machine_type" {
  default     = "n1-standard-2"
  description = "machine type for default node pool"
}

variable "default_storage_type" {
  default     = "pd-ssd"
  description = "storage type for default node pool"
}

/*******************************
Install JupyterHub Using Helm
********************************/

variable "namespace" {
  default     = "jhub"
  description = "name of namespace"
}

variable "helm_version" {
  default     = "0.9.1"
  description = "version of helm chart"
}

variable "proxy_secret_token" {
  description = "secret token for proxy"
}

variable "proxy_https_hosts" {
  description = "domain name"
  type        = list(string)
}

variable "proxy_https_letsencrypt_contactemail" {
  description = "letsencrypt contact email"
}

variable "auth_google_client_id" {
  description = "Client ID"
}

variable "auth_google_client_secret" {
  description = "Client Secret"
}

variable "auth_google_callback_url" {
  description = "Callback URL"
}

variable "singleuser_image_name" {
  description = "name of image"
}

variable "singleuser_image_tag" {
  description = "tag of image"
}

variable "placeholders" {
  description = "number of placeholder pods"
}

variable "admin" {
  type        = list(string)
  description = "admin users"
}