variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_number" {
  description = "The GCP project number"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "access_policy_id" {
  description = "The Access Context Manager policy ID"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for Cloud Armor"
  type        = list(string)
}