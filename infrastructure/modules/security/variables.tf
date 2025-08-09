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

variable "secrets" {
  description = "Map of secrets to create"
  type        = map(string)
  default     = {
    "db-password"           = "Database password",
    "jwt-secret"            = "JWT signing secret",
    "google-client-id"      = "Google OAuth client ID",
    "google-client-secret"  = "Google OAuth client secret",
    "stripe-api-key"        = "Stripe API key",
    "paypal-client-id"      = "PayPal client ID",
    "paypal-client-secret"  = "PayPal client secret",
    "sendgrid-api-key"      = "SendGrid API key",
    "twilio-account-sid"    = "Twilio account SID",
    "twilio-auth-token"     = "Twilio auth token"
  }
}

variable "secret_access" {
  description = "Map of secrets to list of service accounts that can access them"
  type        = map(list(string))
  default     = {}
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for Cloud Armor"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow all by default, should be restricted in production
}