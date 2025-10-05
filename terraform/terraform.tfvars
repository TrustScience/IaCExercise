# Point to your image 
container_image = "914357406929.dkr.ecr.us-west-2.amazonaws.com/iac-exercise:v1"
#container_port  = 80

env_vars = {
  APP_ENV = "prod"
}

cpu         = 512
memory      = 1024
container_port = 8080


desired_count         = 2
enable_fargate_spot   = true
allowed_ingress_cidrs = ["0.0.0.0/0"]

# Diagnostic toggle: temporarily disable ECR interface endpoints so tasks will egress via NAT
disable_ecr_interface_endpoints = false

# Enable TF-managed interface endpoints so we can import existing ECR endpoints
create_interface_endpoints = true

tags = {
  Owner = "SRE"
  App   = "IaC Exercise"
}

assign_public_ip = true  # for testing in private subnets without NAT
