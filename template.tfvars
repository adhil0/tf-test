
/**********************
Provider Configuration
***********************/
project_id = 
region     = 
zone       = 

/***********************************
Create Cluster and Node Pools
************************************/
user_pool_max_nodes    = 
user_pool_machine_type = 
# Not necessary to include because default value set in variables.tf:
# default_machine_type = 
# default_node_count   = 
# user_pool_min_nodes  = 
# user_pool_num_nodes  = 

/*******************************
Install JupyterHub Using Helm
********************************/
proxy_secret_token                   = 
proxy_https_hosts                    = 
proxy_https_letsencrypt_contactemail = 
auth_google_client_id                = 
auth_google_client_secret            =
auth_google_callback_url             =
singleuser_image_name                = 
singleuser_image_tag                 = 
placeholders                         = 
namespace                            = 
admin                                =  #Example: ['user1', 'user2']
# Not necessary to include because default value set in variables.tf:
# helm_version                       = 
