#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
    [string] $ConfigPath
)

$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../lib/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

# Select or create project
if ($resources.gcp_project_id -ne $null) {
    # Select existing project
    $currProjectId = gcloud config get-value project
    if ($currProjectId -ne $resources.gcp_project_id){
        gcloud config set project $($resources.gcp_project_id)
        if ($lastExitCode -eq 0) {
            Write-Host "Project with id $($resources.gcp_project_id) selected."
        }
    }
} else {
    # Create new project
    $resources.gcp_project_id = "$($config.gcp_project_name)".Replace(" ","-").ToLower()
    $create = Read-Host "Do you want to create a new GCP project with id [$($resources.gcp_project_id)]? (y/n)"
    if ($create.ToLower() -eq "y") {
        gcloud projects create $resources.gcp_project_id --name="$($config.gcp_project_name)"
        if ($lastExitCode -eq 0) {
            Write-Host "Project $($config.gcp_project_name) successfully created."
            $resources.gcp_project_number = $(gcloud projects list --format=json --filter="projectId:$($resources.gcp_project_id)" | ConvertFrom-Json).projectNumber
            gcloud config set project $($resources.gcp_project_id)

            # Link new project to billing account
            gcloud alpha billing accounts projects link $resources.gcp_project_id --billing-account="$($config.gcp_billing_account_id)"
        }
    } else {
        Write-Error "Project creation aborded and 'gcp_project_id' is missing in resource file..."
    }
}

# Read ssh key
$pubKey = Get-Content -Path "$path/../$($config.mgmt_instance_pub_ssh_path)"
# # Add escape characters
# $pubKey = $pubKey.Replace(" ", "\ ").Replace("+", "\+")

# Create management station virtual machine
Write-Host "Creating management station virtual machine..."
gcloud beta compute --project="$($resources.gcp_project_id)" instances create "$($config.mgmt_instance_name)" `
    --zone="$($config.mgmt_instance_zone)" `
    --machine-type="$($config.mgmt_instance_size)" `
    --subnet=default `
    --network-tier=PREMIUM `
    --metadata=ssh-keys="$($config.mgmt_instance_pub_ssh_name):$pubKey" `
    --maintenance-policy=MIGRATE `
    --service-account="$($resources.gcp_project_number)-compute@developer.gserviceaccount.com" `
    --scopes="https://www.googleapis.com/auth/cloud-platform" `
    --image="$($config.mgmt_instance_image)" `
    --image-project="$($config.mgmt_instance_image_project)" `
    --boot-disk-size="$($config.mgmt_instance_disk_size)" `
    --boot-disk-type="$($config.mgmt_instance_disk_type)" `
    --boot-disk-device-name="$($config.mgmt_instance_disk_name)" `
    --no-shielded-secure-boot `
    --shielded-vtpm `
    --shielded-integrity-monitoring `
    --labels=environment=mgmt-station `
    --reservation-affinity=any

# Get mgmt station public and private ip
$resources.mgmt_public_ip = $(gcloud compute instances list --format=json --filter="name:$($config.mgmt_instance_name)" | ConvertFrom-Json).networkInterfaces.accessConfigs.natIP
$resources.mgmt_private_ip = $(gcloud compute instances list --format=json --filter="name:$($config.mgmt_instance_name)" | ConvertFrom-Json).networkInterfaces.networkIP

# Write resources
Write-EnvResources -Path $ConfigPath -Resources $resources
