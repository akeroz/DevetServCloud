# Configuration de la machine virtuelle Compute Engine

# Création d'une adresse IP statique externe (optionnelle)
resource "google_compute_address" "vm_static_ip" {
  name   = "${var.project_name}-vm-ip"
  region = var.region
}

# Création de l'instance Compute Engine
resource "google_compute_instance" "vm_instance" {
  name         = "${var.project_name}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  # Tags pour les règles de pare-feu
  tags = var.instance_tags

  # Configuration du disque de démarrage
  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  # Configuration de l'interface réseau
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnetwork.id

    # Attribution d'une IP publique
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  # Métadonnées pour la configuration de la VM
  metadata = {
    ssh-keys = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : null
  }

  # Script de démarrage (optionnel)
  metadata_startup_script = var.startup_script

  # Configuration du service account
  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  # Labels pour l'organisation
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  # Permet de modifier la VM sans la détruire
  allow_stopping_for_update = true

  # Configuration de la disponibilité
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = var.preemptible
  }
}
