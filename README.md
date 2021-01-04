# Setup

First, run `git clone git@github.com:ucsb-pstat/tf-gke-ling226.git` in your terminal.

## If You Are Using the Modules Branch: 

1. Run `gcloud auth application-default login` in your terminal.
2. [Create a Project on Google Cloud Platform](https://console.cloud.google.com/projectcreate).
3. [Make Sure You Have Owner Privileges](https://console.cloud.google.com/iam-admin/iam).
4. [Set Up Billing](https://console.cloud.google.com/billing).
5. Enable the [Google Compute Engine](https://console.developers.google.com/apis/library/compute.googleapis.com) and the [Kubernetes Engine API](https://console.developers.google.com/apis/library/container.googleapis.com).
6. Fill out the `template.tfvars` file with desired parameters or unlock `terraform.tfvars` by adding your GPG key to the authorized key list.
7. Run `terraform init`.  
8. Run `terraform plan -var-file=<file name>.tfvars`, replacing `<file name>` with the name of your .tfvars file.
9. Run `terraform apply -var-file=<file name>.tfvars`, replacing `<file name>` with the name of your .tfvars file.

## If You Are Using the Master Branch:

1. [Create Project on Google Cloud Platform](https://console.cloud.google.com/projectcreate)
2. [Make Sure You Have Owner Privileges](https://console.cloud.google.com/iam-admin/iam) 
3. [Set Up Billing](https://console.cloud.google.com/billing)
4. [Create Service Account](https://console.cloud.google.com/apis/credentials/serviceaccountkey)  
    - Select the project you created from the top dropdown menu
    - Under Service account, select New service account
    - Name it
    - Under Role, choose Project, then Editor
    - Set Key Type to JSON
    - Click Create to create the key and save the key file
5. Download the key file and put it in the same directory as terraform script 
6. [Give the Service Account the Following Roles](https://console.cloud.google.com/iam-admin/iam):
   - Compute Admin (roles/compute.admin)
   - Kubernetes Engine Admin (roles/container.admin)
   - Service Account User (roles/iam.serviceAccountUser)
7. Enable [Google Compute Engine](https://console.developers.google.com/apis/library/compute.googleapis.com) and [Kubernetes Engine API](https://console.developers.google.com/apis/library/container.googleapis.com)
8. Make sure you have a YAML file for the helm chart in the same directory as the terraform files
9. Fill out `template.tfvars` file with desired parameters or unlock `terraform.tfvars` using `git-crypt unlock path/to/key`
10. Run `terraform init`  
11. Run `terraform plan -var-file=template.tfvars`  
12. Run `terraform apply -var-file=template.tfvars` 

