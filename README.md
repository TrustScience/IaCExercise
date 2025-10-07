# IaC Exercise - Terraform

Infrastructure as Code exercise using Terraform to deploy a web server on AWS.

## 📁 Project Structure

```
.
├── infra/                  # Terraform infrastructure code
│   ├── main.tf             # Terraform provider configuration
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── networking.tf       # VPC, subnets, routing
│   └── dev.tfvars          # Dev variable values (modify as needed)
├── webserver/              # Future: Application container files
│   ├── Dockerfile          # Web server container
│   └── static_page/
│       └── index.html      # Static web content
└── .github/workflows/      # CI/CD pipelines
    ├── terraform-ci.yml
    ├── terraform-deploy.yml
    └── README.md
```

## 🚀 Infrastructure Overview

This Terraform configuration creates:

- **VPC** with DNS resolution enabled
- **2 Public Subnets** (for future Application Load Balancer)
- **2 Private Subnets** (for future ECS Fargate services)
- **Internet Gateway** for public access
- **NAT Gateways** for private subnet outbound access
- **Route Tables** for proper traffic routing

## 🛠️ Local Development

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- AWS account with appropriate permissions

### Commands
```bash
# Navigate to infrastructure directory
cd infra/

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

## 🔧 Configuration

### Required Variables
Edit `infra/dev.tfvars` to customize your deployment:

```hcl
aws_region = "ca-central-1"
project_name = "iac-exercise"
environment = "dev"
```

## 🌐 Future Application Deployment

The webserver directory contains application files ready for future ECS Fargate deployment:
- **Dockerfile**: Container configuration for web service
- **static_page/**: Static web content
- Ready for ALB + ECS integration

## 🔄 CI/CD Pipeline

GitHub Actions workflows:
- **terraform-ci.yml**: Validates and tests Terraform code
- **terraform-deploy.yml**: Deploys infrastructure to AWS

See `.github/workflows/README.md` for setup instructions.

## 📊 Outputs

After deployment, Terraform provides:
- `vpc_id`: VPC identifier
- `public_subnet_ids`: Public subnet IDs (for ALB placement)
- `private_subnet_ids`: Private subnet IDs (for ECS services)
- `internet_gateway_id`: Internet Gateway ID
- `nat_gateway_ids`: NAT Gateway IDs

## 🧹 Cleanup

To remove all resources:
```bash
terraform destroy
```

## 📝 Interview Notes

This project demonstrates:
- Infrastructure as Code with Terraform
- AWS networking best practices (VPC, subnets, routing)
- CI/CD integration with GitHub Actions
- Iterative infrastructure development approach
- Clean project organization and documentation
