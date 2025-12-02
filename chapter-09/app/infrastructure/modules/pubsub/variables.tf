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

variable "topics" {
  description = "List of Pub/Sub topics to create"
  type        = list(string)
  default     = [
    "payment-events",
    "user-events",
    "transaction-events",
    "fraud-alerts",
    "notification-events",
    "dead-letter"
  ]
}

variable "subscriptions" {
  description = "Map of subscriptions to create"
  type = map(object({
    topic             = string
    push_endpoint     = string
    service_account   = string
    dead_letter_topic = string
  }))
  default = {}
}

variable "topic_publishers" {
  description = "Map of topics to list of service accounts that can publish"
  type        = map(list(string))
  default     = {}
}

variable "topic_subscribers" {
  description = "Map of topics to list of service accounts that can subscribe"
  type        = map(list(string))
  default     = {}
}

variable "cmek_key_name" {
  description = "The name of the Cloud KMS key for CMEK encryption"
  type        = string
  default     = null
}