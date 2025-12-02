/**
 * Zero Trust Payment Processing - Development Environment
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
  
  backend "gcs" {
    bucket = "zero-trust-payment-terraform-state"
    prefix = "dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Networking module
module "networking" {
  source = "../../modules/networking"
  
  project_id                 = var.project_id
  project_number             = var.project_number
  region                     = var.region
  subnet_cidr                = var.subnet_cidr
  enable_vpc_service_controls = false  # Disabled for dev environment
}

# Security module
module "security" {
  source = "../../modules/security"
  
  project_id = var.project_id
  region     = var.region
  environment = "dev"
  
  secret_access = {
    "db-password" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com",
      "transaction-ledger-sa@${var.project_id}.iam.gserviceaccount.com",
      "fraud-detection-sa@${var.project_id}.iam.gserviceaccount.com",
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com",
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "jwt-secret" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "google-client-id" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "google-client-secret" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "stripe-api-key" = [
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "paypal-client-id" = [
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "paypal-client-secret" = [
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "sendgrid-api-key" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "twilio-account-sid" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "twilio-auth-token" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ]
  }
  
  allowed_ip_ranges = ["0.0.0.0/0"]  # Allow all for dev, restrict in prod
}

# Database module
module "database" {
  source = "../../modules/database"
  
  project_id      = var.project_id
  region          = var.region
  environment     = "dev"
  vpc_network_id  = module.networking.vpc_network_id
  cloud_run_subnet = var.subnet_cidr
  db_tier         = "db-custom-2-4096"  # Smaller instance for dev
  cmek_key_name   = module.security.kms_key_id
}

# Pub/Sub module
module "pubsub" {
  source = "../../modules/pubsub"
  
  project_id = var.project_id
  region     = var.region
  environment = "dev"
  cmek_key_name = module.security.kms_key_id
  
  topic_publishers = {
    "payment-events" = [
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "user-events" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "transaction-events" = [
      "transaction-ledger-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "fraud-alerts" = [
      "fraud-detection-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "notification-events" = [
      "user-management-sa@${var.project_id}.iam.gserviceaccount.com",
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com",
      "fraud-detection-sa@${var.project_id}.iam.gserviceaccount.com"
    ]
  }
  
  topic_subscribers = {
    "payment-events" = [
      "transaction-ledger-sa@${var.project_id}.iam.gserviceaccount.com",
      "fraud-detection-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "user-events" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "transaction-events" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "fraud-alerts" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com",
      "payment-gateway-sa@${var.project_id}.iam.gserviceaccount.com"
    ],
    "notification-events" = [
      "notifications-sa@${var.project_id}.iam.gserviceaccount.com"
    ]
  }
}

# Apigee module
module "apigee" {
  source = "../../modules/apigee"
  
  project_id     = var.project_id
  region         = var.region
  environment    = "dev"
  vpc_network_id = module.networking.vpc_network_id
  domain_name    = "dev.payment-api.example.com"
  cmek_key_name  = module.security.kms_key_id
}

# Cloud Run module
module "cloud_run" {
  source = "../../modules/cloud-run"
  
  project_id            = var.project_id
  region                = var.region
  environment           = "dev"
  vpc_connector_id      = "projects/${var.project_id}/locations/${var.region}/connectors/serverless-vpc-connector"
  apigee_service_account = module.apigee.apigee_service_account
}