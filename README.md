# Setup
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
6. Download the key file and put it in the same directory as terraform script 
7. [Give the Service Account the Following Roles](https://console.cloud.google.com/iam-admin/iam):
   - Compute Admin (roles/compute.admin)
   - Kubernetes Engine Admin (roles/container.admin)
   - Service Account User (roles/iam.serviceAccountUser)
14. Enable [Google Compute Engine](https://console.developers.google.com/apis/library/compute.googleapis.com) and [Kubernetes Engine API](https://console.developers.google.com/apis/library/container.googleapis.com)
15. Fill out `template.tfvars` file with desired parameters 
16. Run `terraform init`  
17. Run `terraform plan -var-file=template.tfvars`  
18. Run `terraform apply -var-file=template.tfvars` 
