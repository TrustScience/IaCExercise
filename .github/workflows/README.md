# GitHub Actions Workflows for Terraform

This repository contains two GitHub Actions workflows for your Terraform interview project.

## 1. `terraform-ci.yml` - CI Pipeline

**Triggers:**
- Push to `main` or `develop` branches  
- Pull requests to `main`
- Manual trigger via GitHub UI (workflow_dispatch)

**What it does:**
- ✅ Validates Terraform syntax with `terraform validate`
- ✅ Checks code formatting with `terraform fmt`
- ✅ Initializes with S3 backend
- ✅ Creates execution plan with `terraform plan`
- ✅ Runs security scanning with Checkov
- ✅ Uploads Terraform plan as artifacts

## 2. `terraform-deploy.yml` - Simple Dev Deployment

**Triggers:**
- Push to `main` branch (auto-deploys to dev)
- Manual trigger via GitHub UI

**Environment:**
- **Development**: Single environment for interview demo

## Setup Required

### 1. Repository Secrets
Add these secrets in your GitHub repository settings:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 2. Repository Variables
Add these variables in your GitHub repository settings:

```
AWS_REGION=ca-central-1
```

### 3. Environment Protection (Optional)
For interview purposes, you can leave the development environment unprotected for automatic deployment.

## Manual Deployment
To manually trigger a deployment:
1. Go to Actions → Terraform Deploy to Dev
2. Click "Run workflow"
3. Click "Run workflow" to confirm

## Manual CI Run
To manually run the CI pipeline:
1. Go to Actions → Terraform CI
2. Click "Run workflow"
3. Select branch and click "Run workflow"

## AWS Permissions
Your AWS IAM user/role needs these permissions:
- EC2 full access (for VPCs, subnets, security groups)
- IAM permissions for creating roles/policies
- **S3 access for Terraform remote state backend**
  - Read/Write to `iacexercise-tfstate` bucket
  - `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`
- Permissions for any AWS services your stack uses

## S3 Backend Setup
The Terraform state is stored remotely in S3:
- **Bucket**: `iacexercise-tfstate`
- **Key**: `dev.tfstate`
- **Region**: `ca-central-1`

Make sure this bucket exists before running Terraform or the pipelines.

## Terraform Commands
Common commands for local development:

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```