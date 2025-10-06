# Architecture overview

This Terraform project provisions a AWS VPC in two Availability Zones (AZs) for fault tolerance and high availability.  
It creates a **Multi-AZ VPC** with **public/private subnets**, **per-AZ NAT Gateways**, **VPC Flow Logs**, and deploys an **ECS Fargate service** connected to a **private ECR repository** behind an **Application Load Balancer (ALB)**.

---

## Core Components

### 1. **VPC**
- CIDR: e.g., `10.0.0.0/16`
- DNS hostnames and DNS support enabled
- Isolated, dedicated network for workloads

---

### 2. **Subnets (Multi-AZ)**
- **Public Subnets (x2):**
  - One per AZ (e.g., `10.0.0.0/20`, `10.0.16.0/20`)
  - Host ALB, NAT Gateways
  - Auto-assign public IPs

- **Private Subnets (x2):**
  - One per AZ (e.g., `10.0.32.0/20`, `10.0.48.0/20`)
  - Host ECS tasks, EKS nodes, or databases
  - No direct internet access

---

### 3. **Internet Gateway (IGW)**
- Attached to the VPC
- Enables outbound access for public subnets
- Used for inbound ALB or bastion connectivity

---

### 4. **NAT Gateways (per AZ)**
- One NAT Gateway per AZ for fault tolerance
- Private subnets route outbound traffic to their local NAT
- Ensures resiliency during single-AZ failure

---

### 5. **Route Tables**
- **Public Route Table:** default route → Internet Gateway
- **Private Route Tables (per AZ):** default route → NAT Gateway

---

### 6. **VPC Endpoints (optional)**
- **Gateway Endpoints:** for S3 — keep traffic inside AWS backbone  
- **Interface Endpoints:** for SSM, EC2, CloudWatch, ECR — secure private API access

---

### 7. **VPC Flow Logs → CloudWatch**
- Captures ACCEPT / REJECT / ALL traffic metadata
- Sent to CloudWatch Log Group: `/vpc/<project>/flow-logs`
- IAM Role with least privilege for logging
- Enables audit, security, and performance analysis

---

### 8. **ECS Fargate Cluster & Tasks**
- Cluster with container insights enabled
- Task definitions define containers, CPU/memory, and environment variables
- Pulls Docker image from private ECR
- Runs in private subnets (no public IP)
- Logs sent to CloudWatch Logs

---

### 9. **Application Load Balancer (ALB)**
- Deployed in public subnets
- Routes inbound traffic to ECS tasks in private subnets
- Supports HTTP and optional HTTPS via ACM certificate
- Health checks and circuit breakers for resilience

---

# Security Considerations

- **Network Isolation** Private workloads only reachable via ALB. No public IPs on ECS tasks 
- **Per-AZ NAT Gateways** AZ-specific egress preventing cross-AZ dependency
- **Security Groups** ALB SG ingress from trusted CIDRs only. Tasks SG only allows ALB ingress
- **IAM Roles** Separate task & execution roles. Principle of least privilege enforced |
- **Logging & Audit**  VPC Flow Logs and CloudWatch |
- **ECR Hygiene**  Private repo 
- **Observability**  CloudWatch metrics & logs. Supports alerts and dashboards

---

# Deployment Steps

1. **Container Image**

- aws ecr get-login-password --region <region> \
  | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
- docker build -t <app> .
- docker tag <app>:latest <account>.dkr.ecr.<region>.amazonaws.com/<app>:v1
- docker push <account>.dkr.ecr.<region>.amazonaws.com/<app>:v1

- Update container image name in terraform.tfvars file wiht the newly built container and save file.

2. **Initialize Terraform**
   Run the following commands to initialize and deploy VPC and ECS services:

- terraform init
- terraform plan -out tf.plan
- terraform apply tf.plan
- terraform output alb_dns_name for application dns name
