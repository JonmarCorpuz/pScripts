# ==== PROVIDERS ==========================================================

terraform {

  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    
    google-beta = {
      source  = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project     = "PROJECT_ID"
  region      = "PROJECT_REGION"
  credentials = "keys.json"
}

provider "google-beta" {
  project     = "PROJECT_ID"
  region      = "PROJECT_REGION"
  credentials = "keys.json"
#  alias       = "google-beta"
}

# ==== FIREWALL POLICIES ==================================================

# Allow Health Check Traffic
resource "google_compute_firewall" "allow_health_check" {
  name          = "PROJECT_ID-lb-fw-allow-health-check"
  direction     = "INGRESS"
  network       = google_compute_network.vpc-network.id
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags = ["allow-health-check"]

  allow {
    protocol = "tcp"
  }

  log_config {
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# Allow all traffic
resource "google_compute_firewall" "allow-all" {
  name          = "PROJECT_ID-allow-all-test"
  direction     = "INGRESS"
  network       = google_compute_network.vpc-network.id
  source_ranges = ["0.0.0.0"]
  target_tags = ["allow-all"]

  allow {
    protocol = "tcp"
  }

  log_config {
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}


# ==== NETWORKING =========================================================

# Virtual Private Cloud 
resource "google_compute_network" "vpc-network" {
  project                 = "PROJECT_ID"
  name                    = "PROJECT_ID-vpc"
  auto_create_subnetworks = false
}

# Backend Subnet
resource "google_compute_subnetwork" "vpc-private-subnet" {
  project       = "PROJECT_ID"
  name          = "PROJECT_ID-private-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.project_region
  network       = google_compute_network.vpc-network.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Proxy Subnet
resource "google_compute_subnetwork" "vpc-proxy-subnet" {
  name          = "PROJECT_ID-lb-proxy-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = "PROJECT_REGION"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc-network.id
}

# ==== INSTANCE TEMPLATE ==================================================

# Instance Template 
resource "google_compute_instance_template" "mig-template" {
  name                 = "PROJECT_ID-template"
  instance_description = "An instance template for the stateful MIG."
  machine_type         = "MACHINE_TYPE"
  tags                 = ["allow-health-check","allow-all"]

  network_interface {
    network    = "PROJECT_ID-vpc"
    subnetwork = "PROJECT_ID-private-subnet"
    access_config {

    }
  }

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  metadata_startup_script = file("./startupScript.sh")

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_compute_network.vpc-network,
    google_compute_subnetwork.vpc-private-subnet
  ]

}

# ==== HEALTH CHECKS ======================================================

# Instance Group Health Check
resource "google_compute_health_check" "mig-health-check" {
  name                = "PROJECT_ID-mig-health-check"
  description         = "Health check via http"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5

  http_health_check {
    port_name    = "http"
    port         = 80
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# ==== MANAGED INSTANCE GROUP =============================================

# Stateful Managed Regional Instance Group 
resource "google_compute_region_instance_group_manager" "stateful-mig" {

  name     = "PROJECT_ID-stateful-mig"
  region     = "PROJECT_REGION"
  base_instance_name = "PROJECT_ID-managed-vm"
  target_size        = MINIMUM_INSTANCES

  named_port {
    name = "http"
    port = 80
  }

  version {
    instance_template = google_compute_instance_template.mig-template.id
    name              = "primary"
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.mig-health-check.id
    initial_delay_sec = 300
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# ==== EXTERNAL LOAD BALANCER =============================================

# Load Balancer Reserved Public IP Address 
resource "google_compute_global_address" "lb-reserved-public-address" {
  name         = "PROJECT_ID-lb-static-ip"
  description  = "The reserved static IP address for the load balancer."
  address_type = "EXTERNAL"

    depends_on = [
    google_compute_network.vpc-network
  ]

}

# Load Balancer Forwarding Rule
resource "google_compute_global_forwarding_rule" "http-proxy-forwarding-rule" {
  name                  = "PROJECT_ID-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.lb-http-proxy.id
  ip_address            = google_compute_global_address.lb-reserved-public-address.id

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# Load Balancer HTTP Proxy
resource "google_compute_target_http_proxy" "lb-http-proxy" {
  name        = "PROJECT_ID-lb-target-http-proxy"
  description = "The HTTP Proxy that'll redirect traffic to the load balancer."
  url_map     = google_compute_url_map.lb-url-map.id

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# Host and Path Rules (URL Map)
resource "google_compute_url_map" "lb-url-map" {
  name            = "PROJECT_ID-load-balancer"
  description     = "Route request sent to the HTTP Proxy to the backend service."
  default_service = google_compute_backend_service.lb-backend-service.id

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# Load Balancer Backend Service
resource "google_compute_backend_service" "lb-backend-service" {
  name                    = "PROJECT_ID-lb-backend-service"
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL_MANAGED"
  timeout_sec             = 10
  enable_cdn              = true
  health_checks           = [google_compute_health_check.lb-health-check.id]

  backend {
    group           = google_compute_region_instance_group_manager.stateful-mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}

# Load Balancer Health Check
resource "google_compute_health_check" "lb-health-check" {
  name     = "PROJECT_ID-lb-health-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }

  depends_on = [
    google_compute_network.vpc-network
  ]

}
