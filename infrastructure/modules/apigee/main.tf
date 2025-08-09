/**
 * Zero Trust Apigee Infrastructure
 * 
 * This module sets up Apigee API Gateway with security policies
 * and access controls.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

# Create Apigee organization
resource "google_apigee_organization" "org" {
  analytics_region                     = var.region
  project_id                           = var.project_id
  authorized_network                   = var.vpc_network_id
  runtime_type                         = "CLOUD"
  billing_type                         = "PAYG"
  runtime_database_encryption_key_name = var.cmek_key_name
}

# Create Apigee environment
resource "google_apigee_environment" "env" {
  name         = var.environment
  description  = "Apigee environment for ${var.environment}"
  display_name = "${var.environment} Environment"
  org_id       = google_apigee_organization.org.id
}

# Create Apigee environment group
resource "google_apigee_envgroup" "env_group" {
  name      = "${var.environment}-group"
  hostnames = ["api.${var.domain_name}"]
  org_id    = google_apigee_organization.org.id
}

# Attach environment to environment group
resource "google_apigee_envgroup_attachment" "env_attachment" {
  envgroup_id = google_apigee_envgroup.env_group.id
  environment = google_apigee_environment.env.name
}

# Create service account for Apigee to invoke Cloud Run
resource "google_service_account" "apigee_sa" {
  account_id   = "apigee-cloud-run-sa"
  display_name = "Apigee Service Account for Cloud Run"
  description  = "Service account for Apigee to invoke Cloud Run services"
}

# Grant Cloud Run invoker role to Apigee service account
resource "google_project_iam_member" "apigee_cloud_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.apigee_sa.email}"
}

# Create API products for different microservices
resource "google_apigee_product" "products" {
  for_each = toset(var.api_products)
  
  name                   = "${each.value}-product"
  display_name           = "${each.value} API Product"
  description            = "API Product for ${each.value} microservice"
  approval_type          = "AUTO"
  quota                  = 1000
  quota_interval         = "1"
  quota_time_unit        = "MINUTE"
  attributes             = {
    access               = "private"
    environment          = var.environment
  }
  
  environments           = [google_apigee_environment.env.name]
  resources              = ["/"]
  
  operation_group {
    operation_configs {
      api_source        = each.value
      operations        = ["/"]
      quota             = 100
      quota_interval    = "1"
      quota_time_unit   = "MINUTE"
    }
  }
}

# Create developer for API access
resource "google_apigee_developer" "developer" {
  email      = "developer@${var.domain_name}"
  first_name = "API"
  last_name  = "Developer"
  username   = "api-developer"
  org_id     = google_apigee_organization.org.id
}

# Create developer app for API access
resource "google_apigee_developer_app" "app" {
  name         = "payment-processing-app"
  developer_id = google_apigee_developer.developer.email
  org_id       = google_apigee_organization.org.id
  
  api_products = [for product in google_apigee_product.products : product.name]
  
  attributes = {
    displayName = "Payment Processing App"
    environment = var.environment
  }
}