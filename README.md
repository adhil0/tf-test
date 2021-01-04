# Setup
Make sure you have [Terraform](https://www.terraform.io/downloads.html) installed.
1. Run `git clone git@github.com:ucsb-pstat/tf-gke-geog111.git` in your terminal.
2. Run `gcloud auth application-default login` in your terminal.
3. [Create a Project on Google Cloud Platform](https://console.cloud.google.com/projectcreate).
4. [Make Sure You Have Owner Privileges](https://console.cloud.google.com/iam-admin/iam).
5. [Set Up Billing](https://console.cloud.google.com/billing).
6. Enable the [Google Compute Engine](https://console.developers.google.com/apis/library/compute.googleapis.com) and the [Kubernetes Engine API](https://console.developers.google.com/apis/library/container.googleapis.com).
7. Fill out the `template.tfvars` file with desired parameters or unlock `terraform.tfvars` by adding your GPG key to the authorized key list.
8. Run `terraform init`.  
8. Run `terraform plan -var-file=<file name>.tfvars`, replacing `<file name>` with the name of your .tfvars file.
10. Run `terraform apply -var-file=<file name>.tfvars`, replacing `<file name>` with the name of your .tfvars file.
