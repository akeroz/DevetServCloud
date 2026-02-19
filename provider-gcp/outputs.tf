# Outputs pour afficher les informations importantes après le déploiement

# Informations réseau
output "vpc_network_name" {
  description = "Nom du VPC créé"
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_id" {
  description = "ID du VPC créé"
  value       = google_compute_network.vpc_network.id
}

output "subnet_name" {
  description = "Nom du sous-réseau créé"
  value       = google_compute_subnetwork.vpc_subnetwork.name
}

output "subnet_cidr" {
  description = "Plage CIDR du sous-réseau"
  value       = google_compute_subnetwork.vpc_subnetwork.ip_cidr_range
}

# Informations de la VM
output "vm_instance_name" {
  description = "Nom de l'instance VM"
  value       = google_compute_instance.vm_instance.name
}

output "vm_instance_id" {
  description = "ID de l'instance VM"
  value       = google_compute_instance.vm_instance.instance_id
}

output "vm_machine_type" {
  description = "Type de machine de la VM"
  value       = google_compute_instance.vm_instance.machine_type
}

output "vm_zone" {
  description = "Zone de la VM"
  value       = google_compute_instance.vm_instance.zone
}

# Informations IP
output "vm_internal_ip" {
  description = "Adresse IP interne de la VM"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "Adresse IP publique de la VM"
  value       = google_compute_address.vm_static_ip.address
}

# Informations de connexion
output "ssh_connection_command" {
  description = "Commande pour se connecter à la VM via SSH"
  value       = "ssh ${var.ssh_user}@${google_compute_address.vm_static_ip.address}"
}

output "web_url" {
  description = "URL pour accéder au serveur web (si nginx est installé)"
  value       = "http://${google_compute_address.vm_static_ip.address}"
}

# Informations de configuration
output "firewall_rules" {
  description = "Liste des règles de pare-feu créées"
  value = {
    ssh       = google_compute_firewall.allow_ssh.name
    http_https = google_compute_firewall.allow_http_https.name
    internal  = google_compute_firewall.allow_internal.name
  }
}
