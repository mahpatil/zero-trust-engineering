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

variable "microservices" {
  description = "List of microservices to deploy"
  type        = list(string)
  default     = ["user-management", "transaction-ledger", "fraud-detection", "payment-gateway", "notifications"]
}

variable "vpc_connector_id" {
  description = "The ID of the VPC connector for Cloud Run"
  type        = string
}

variable "apigee_service_account" {
  description = "The service account email for Apigee to invoke Cloud Run services"
  type        = string
}