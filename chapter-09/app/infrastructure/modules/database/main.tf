/**
 * Zero Trust Database Infrastructure
 * 
 * This module sets up Cloud SQL instances with private IP,
 * encryption, and strict access controls.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "main" {
  name             = "${var.project_id}-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  region           = var.region
  
  settings {
    tier = var.db_tier
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
      
      authorized_networks {
        name  = "cloud-run"
        value = var.cloud_run_subnet
      }
    }
    
    backup_configuration {
      enabled            = true
      binary_log_enabled = false
      start_time         = "02:00"
      point_in_time_recovery_enabled = true
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 2  # 2 AM
      update_track = "stable"
    }
    
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }
    
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }
    
    database_flags {
      name  = "log_min_error_statement"
      value = "error"
    }
    
    database_flags {
      name  = "log_temp_files"
      value = "0"
    }
    
    user_labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }
  
  deletion_protection = true
  
  encryption_key_name = var.cmek_key_name
}

# Create databases for each microservice
resource "google_sql_database" "user_management_db" {
  name     = "user_management"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database" "transaction_ledger_db" {
  name     = "transaction_ledger"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database" "fraud_detection_db" {
  name     = "fraud_detection"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database" "payment_gateway_db" {
  name     = "payment_gateway"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database" "notifications_db" {
  name     = "notifications"
  instance = google_sql_database_instance.main.name
}

# Create users for each microservice with IAM authentication
resource "google_sql_user" "user_management_user" {
  name     = "user-management-sa"
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_user" "transaction_ledger_user" {
  name     = "transaction-ledger-sa"
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_user" "fraud_detection_user" {
  name     = "fraud-detection-sa"
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_user" "payment_gateway_user" {
  name     = "payment-gateway-sa"
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_user" "notifications_user" {
  name     = "notifications-sa"
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}