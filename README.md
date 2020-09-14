# Overview

This is a template for management station hosted on google cloud. Management station used to manage environment by environment management project [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 

# Usage

- Download this repository
- Copy *config.example.json* and create own config file
- Set the required values in own config file
- If you never used gcloud cli on your machine run *gcloud_init.ps1* to initialize gcloud cli 
- Run root scripts (*create_mgmt.ps1*/*destroy_mgmt.ps1*)

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| gcp_billing_account_id | XXXXXX-XXXXXX-XXXXXX | Id of your billing account, can be get from https://console.cloud.google.com/billing |
| gcp_project_name | pip Templates | Name of google project |
| mgmt_instance_name | pip-templates-mgmt | Name of management station VM |
| mgmt_instance_zone | us-east1-b | Management VM availability zone |
| mgmt_instance_size | e2-micro | Management station virtual machine size |
| mgmt_instance_pub_ssh_name | pip-templates | Name of ssh key to access management station |
| mgmt_instance_pub_ssh_path | config/id_rsa.pub | Path to public ssh key |
| mgmt_instance_image | ubuntu-1604-xenial-v20200908 | Google image used for management station |
| mgmt_instance_image_project | ubuntu-os-cloud | Google image project used for management station |
| mgmt_instance_disk_size | 10GB | Management station disk size |
| mgmt_instance_disk_type | pd-standard | Google management station disk type |
| mgmt_instance_disk_name | pip-templates-mgmt-disk | Management station disk name |
