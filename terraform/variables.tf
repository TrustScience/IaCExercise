variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "project" {
  type        = string
  description = "Used for naming and tags"
  default     = "iac-exercise-multi-az-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to span (min 2)"
  default     = 2
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "container_image" {
  type        = string
  description = "Container image (ECR URI or public image)"
}

variable "container_port" {
  type        = number
  default     = 80
}

variable "desired_count" {
  type        = number
  default     = 2
}

variable "enable_fargate_spot" {
  type        = bool
  default     = true
}

variable "cpu" {
  description = "Task CPU units (e.g., 256, 512, 1024)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Task memory in MiB (e.g., 1024, 2048)"
  type        = number
  default     = 1024
}

variable "health_check_path" {
  type        = string
  default     = "/"
}

variable "env_vars" {
  description = "Environment variables for the container"
  type = map(string)
  default = {}
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to hit the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_idle_timeout" {
  type        = number
  default     = 60
}

variable "create_interface_endpoints" {
  type        = bool
  description = "Whether to create common interface endpoints (SSM, EC2 Messages, etc.)"
  default     = false
}

variable "create_gateway_endpoints" {
  type        = bool
  default     = true
}

variable "disable_ecr_interface_endpoints" {
  description = "If true, do not create ECR interface endpoints (ecr.api and ecr.dkr). Useful for testing NAT egress vs endpoint routing."
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Optional S3 bucket name to grant the ECS task access to. If empty, the task role will receive AmazonS3ReadOnlyAccess (managed)."
  type        = string
  default     = ""
}

variable "s3_bucket_write" {
  description = "If true and s3_bucket_name is set, allow write actions (PutObject/DeleteObject) on the bucket's objects. (Not implemented in this minimal change.)"
  type        = bool
  default     = false
}

variable "ssm_param_names" {
  type        = list(string)
  default     = []
  description = "SSM parameter paths to mount as secrets"
}

# Optional HTTPS
# variable "enable_https" {
#   type        = bool
#   description = "Create HTTPS listener on 443"
#   default     = false
# }

# variable "acm_certificate_arn" {
#   type        = string
#   description = "ACM cert ARN for HTTPS (required if enable_https = true)"
#   default     = ""
# }

# Optional: if HTTPS enabled, should HTTP 80 redirect?
variable "http_redirect_to_https" {
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign public IPs to tasks in private subnets (for testing without NAT)"
  default     = false
}

variable "flow_logs_enabled" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention for VPC Flow Logs"
  type        = number
  default     = 30
}

variable "flow_logs_traffic_type" {
  description = "Traffic captured by flow logs: ACCEPT | REJECT | ALL"
  type        = string
  default     = "ALL"
}

variable "alarm_sns_topic_arn" {
  description = "Optional SNS topic ARN to notify on image pull errors"
  type        = string
  default     = ""
}
