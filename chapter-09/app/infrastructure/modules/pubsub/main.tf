/**
 * Zero Trust Pub/Sub Infrastructure
 * 
 * This module sets up Pub/Sub topics and subscriptions with
 * encryption and access controls.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

# Define Pub/Sub topics for microservice communication
resource "google_pubsub_topic" "topics" {
  for_each = toset(var.topics)
  name     = each.value
  
  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
  
  # Enable CMEK encryption if key is provided
  dynamic "kms_key_name" {
    for_each = var.cmek_key_name != null ? [1] : []
    content {
      name = var.cmek_key_name
    }
  }
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Create subscriptions for each topic
resource "google_pubsub_subscription" "subscriptions" {
  for_each = var.subscriptions
  
  name    = each.key
  topic   = google_pubsub_topic.topics[each.value.topic].name
  
  # Configure push subscription for Cloud Run
  dynamic "push_config" {
    for_each = each.value.push_endpoint != null ? [1] : []
    content {
      push_endpoint = each.value.push_endpoint
      
      attributes = {
        x-goog-version = "v1"
      }
      
      # Configure authentication for push
      oidc_token {
        service_account_email = each.value.service_account
      }
    }
  }
  
  # Configure pull subscription
  dynamic "retry_policy" {
    for_each = each.value.push_endpoint == null ? [1] : []
    content {
      minimum_backoff = "10s"
      maximum_backoff = "600s"
    }
  }
  
  # Configure dead letter policy
  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_topic != null ? [1] : []
    content {
      dead_letter_topic     = google_pubsub_topic.topics[each.value.dead_letter_topic].id
      max_delivery_attempts = 5
    }
  }
  
  # Configure message retention
  message_retention_duration = "604800s"  # 7 days
  retain_acked_messages      = true
  
  # Configure expiration policy
  expiration_policy {
    ttl = "2592000s"  # 30 days
  }
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# IAM for Pub/Sub topics
resource "google_pubsub_topic_iam_binding" "topic_publishers" {
  for_each = var.topic_publishers
  
  topic   = google_pubsub_topic.topics[each.key].name
  role    = "roles/pubsub.publisher"
  members = [for sa in each.value : "serviceAccount:${sa}"]
}

resource "google_pubsub_topic_iam_binding" "topic_subscribers" {
  for_each = var.topic_subscribers
  
  topic   = google_pubsub_topic.topics[each.key].name
  role    = "roles/pubsub.subscriber"
  members = [for sa in each.value : "serviceAccount:${sa}"]
}