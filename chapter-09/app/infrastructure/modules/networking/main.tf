/**
 * Zero Trust Networking Infrastructure
 * 
 * This module sets up the VPC network with private subnets, Cloud NAT,
 * and VPC Service Controls for zero trust network architecture.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  description             = "VPC Network for Zero Trust Payment Processing"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.project_id}-private-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router for NAT gateway
resource "google_compute_router" "router" {
  name    = "${var.project_id}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

# NAT gateway for private instances to access internet
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${var.project_id}-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule to allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_id}-allow-internal"
  network = google_compute_network.vpc_network.id
  
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.subnet_cidr]
}

# Firewall rule to allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.project_id}-allow-health-checks"
  network = google_compute_network.vpc_network.id
  
  allow {
    protocol = "tcp"
    ports    = ["8080", "80", "443"]
  }
  
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["http-server", "https-server"]
}

# VPC Service Controls perimeter
resource "google_access_context_manager_service_perimeter" "service_perimeter" {
  count = var.enable_vpc_service_controls ? 1 : 0
  
  parent         = "accessPolicies/${var.access_policy_id}"
  name           = "accessPolicies/${var.access_policy_id}/servicePerimeters/payment_processing"
  title          = "Payment Processing Perimeter"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  
  status {
    restricted_services = [
      "cloudfunctions.googleapis.com",
      "cloudrun.googleapis.com",
      "sqladmin.googleapis.com",
      "storage.googleapis.com",
      "pubsub.googleapis.com"
    ]
    
    resources = [
      "projects/${var.project_number}"
    ]
    
    access_levels = [
      "accessPolicies/${var.access_policy_id}/accessLevels/trusted_access"
    ]
  }
}