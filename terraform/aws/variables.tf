variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-example"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "azs" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "environment" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_admin_role_arn" {
  description = "ARN of the IAM role for EKS admin access"
  type        = string
}
