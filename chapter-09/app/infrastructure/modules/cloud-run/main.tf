/**
 * Zero Trust Cloud Run Infrastructure
 * 
 * This module sets up Cloud Run services with private networking,
 * IAM, and security configurations.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

# Create service accounts for each microservice
resource "google_service_account" "service_accounts" {
  for_each     = toset(var.microservices)
  account_id   = "${each.value}-sa"
  display_name = "Service Account for ${each.value} microservice"
  description  = "Zero Trust service account for ${each.value} microservice"
}

# Grant minimal IAM permissions to service accounts
resource "google_project_iam_member" "cloud_run_invoker" {
  for_each = toset(var.microservices)
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.service_accounts[each.value].email}"
}

resource "google_project_iam_member" "logging_writer" {
  for_each = toset(var.microservices)
  project  = var.project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.service_accounts[each.value].email}"
}

resource "google_project_iam_member" "metrics_writer" {
  for_each = toset(var.microservices)
  project  = var.project_id
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${google_service_account.service_accounts[each.value].email}"
}

# Cloud Run services for each microservice
resource "google_cloud_run_service" "microservices" {
  for_each = toset(var.microservices)
  name     = each.value
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${each.value}:latest"
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment
        }
        
        # Add secure environment configuration
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }
      }
      
      service_account_name = google_service_account.service_accounts[each.value].email
      
      # Container security context
      container_concurrency = 80
      timeout_seconds       = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/ingress"              = "internal"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
  
  # IAM policy for the Cloud Run service
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"],
      metadata[0].annotations["run.googleapis.com/operation-id"],
    ]
  }
}

# IAM policy for Cloud Run services - restrict access
resource "google_cloud_run_service_iam_policy" "noauth" {
  for_each    = toset(var.microservices)
  location    = google_cloud_run_service.microservices[each.value].location
  project     = var.project_id
  service     = google_cloud_run_service.microservices[each.value].name
  policy_data = data.google_iam_policy.noauth.policy_data
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${var.apigee_service_account}"
    ]
  }
}