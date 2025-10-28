variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "gke-example"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

variable "environment" {
  description = "Environment type"
  type        = string
  default     = "production"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}