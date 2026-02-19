# Variables pour la configuration GCP

# Variables obligatoires
variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "project_name" {
  description = "Nom du projet (utilisé pour nommer les ressources)"
  type        = string
  default     = "my-gcp-project"
}

# Variables de localisation
variable "region" {
  description = "Région GCP pour déployer les ressources"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone GCP pour déployer la VM"
  type        = string
  default     = "europe-west1-b"
}

# Variables réseau
variable "subnet_cidr" {
  description = "Plage CIDR pour le sous-réseau"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_sources" {
  description = "Liste des plages IP autorisées pour SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] # À restreindre en production!
}

# Variables de la VM
variable "machine_type" {
  description = "Type de machine pour l'instance Compute Engine"
  type        = string
  default     = "e2-micro" # Niveau gratuit GCP
}

variable "boot_disk_image" {
  description = "Image du disque de démarrage"
  type        = string
  default     = "debian-cloud/debian-11"
  # Autres options populaires:
  # - "ubuntu-os-cloud/ubuntu-2204-lts"
  # - "centos-cloud/centos-stream-9"
  # - "rocky-linux-cloud/rocky-linux-9"
}

variable "boot_disk_size" {
  description = "Taille du disque de démarrage en GB"
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "Type de disque de démarrage"
  type        = string
  default     = "pd-standard"
  # Options: pd-standard, pd-balanced, pd-ssd
}

variable "instance_tags" {
  description = "Tags réseau pour l'instance"
  type        = list(string)
  default     = ["ssh-enabled", "web-server"]
}

# Variables SSH
variable "ssh_user" {
  description = "Nom d'utilisateur pour la connexion SSH"
  type        = string
  default     = "terraform-user"
}

variable "ssh_public_key" {
  description = "Clé publique SSH pour l'accès à la VM (format: ssh-rsa AAAA...)"
  type        = string
  default     = ""
}

# Script de démarrage
variable "startup_script" {
  description = "Script à exécuter au démarrage de la VM"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>VM déployée avec Terraform sur GCP</h1>" > /var/www/html/index.html
  EOF
}

# Service Account
variable "service_account_email" {
  description = "Email du service account à utiliser (laisser vide pour utiliser le défaut)"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Scopes pour le service account"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

# Variables diverses
variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "preemptible" {
  description = "Utiliser une instance préemptible (moins chère mais peut être arrêtée)"
  type        = bool
  default     = false
}
