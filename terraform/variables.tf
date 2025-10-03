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
