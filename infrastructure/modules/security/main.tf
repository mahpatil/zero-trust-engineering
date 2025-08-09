/**
 * Zero Trust Security Infrastructure
 * 
 * This module sets up security components including KMS keys,
 * Secret Manager, and security policies.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

# Create KMS keyring
resource "google_kms_key_ring" "keyring" {
  name     = "${var.project_id}-keyring"
  location = var.region
}

# Create KMS key for data encryption
resource "google_kms_crypto_key" "crypto_key" {
  name            = "${var.project_id}-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"  # 90 days
  
  purpose = "ENCRYPT_DECRYPT"
  
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

# Create Secret Manager secrets
resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets
  
  secret_id = each.key
  
  replication {
    automatic = true
  }
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Grant access to secrets for service accounts
resource "google_secret_manager_secret_iam_binding" "secret_access" {
  for_each = var.secret_access
  
  secret_id = google_secret_manager_secret.secrets[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  members   = [for sa in each.value : "serviceAccount:${sa}"]
}

# Create security policy for Cloud Armor
resource "google_compute_security_policy" "policy" {
  name        = "${var.project_id}-security-policy"
  description = "Security policy for API endpoints"
  
  # Default rule to deny all traffic
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny rule"
  }
  
  # Allow rule for specific IP ranges
  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ip_ranges
      }
    }
    description = "Allow traffic from specified IP ranges"
  }
  
  # Block SQL injection attacks
  rule {
    action   = "deny(403)"
    priority = "2000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "Block SQL injection attacks"
  }
  
  # Block XSS attacks
  rule {
    action   = "deny(403)"
    priority = "2001"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS attacks"
  }
  
  # Block local file inclusion attacks
  rule {
    action   = "deny(403)"
    priority = "2002"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('lfi-stable')"
      }
    }
    description = "Block local file inclusion attacks"
  }
  
  # Rate limiting rule
  rule {
    action   = "rate_based_ban"
    priority = "3000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
    }
    description = "Rate limiting rule"
  }
}