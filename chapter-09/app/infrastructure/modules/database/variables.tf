variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_network_id" {
  description = "The ID of the VPC network"
  type        = string
}

variable "cloud_run_subnet" {
  description = "CIDR range for Cloud Run services"
  type        = string
}

variable "db_tier" {
  description = "The machine type for the database instance"
  type        = string
  default     = "db-custom-2-4096"
}

variable "cmek_key_name" {
  description = "The name of the Cloud KMS key for CMEK encryption"
  type        = string
  default     = null
}