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

variable "domain_name" {
  description = "Domain name for API endpoints"
  type        = string
}

variable "api_products" {
  description = "List of API products to create"
  type        = list(string)
  default     = ["user-management", "transaction-ledger", "fraud-detection", "payment-gateway", "notifications"]
}

variable "cmek_key_name" {
  description = "The name of the Cloud KMS key for CMEK encryption"
  type        = string
  default     = null
}