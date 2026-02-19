# Configuration du VPC (Virtual Private Cloud)

# Création du VPC personnalisé
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  description             = "VPC pour le projet ${var.project_name}"
}

# Création d'un sous-réseau dans le VPC
resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Sous-réseau pour les VMs"

  # Activation des logs de flux pour le monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Règle de pare-feu pour autoriser SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_sources
  target_tags   = ["ssh-enabled"]
  description   = "Autoriser SSH depuis les IPs spécifiées"
}

# Règle de pare-feu pour autoriser HTTP/HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-allow-http-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  description   = "Autoriser le trafic HTTP et HTTPS"
}

# Règle de pare-feu pour autoriser le trafic interne
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  description   = "Autoriser tout le trafic interne au VPC"
}
