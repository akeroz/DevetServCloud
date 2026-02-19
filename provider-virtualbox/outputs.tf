# Outputs pour afficher les informations des VMs

output "web_server_name" {
  description = "Nom de la VM serveur web"
  value       = virtualbox_vm.web_server.name
}

output "web_server_ip" {
  description = "Adresse IP du serveur web"
  value       = virtualbox_vm.web_server.network_adapter[0].ipv4_address
}

output "db_server_name" {
  description = "Nom de la VM serveur de base de données"
  value       = virtualbox_vm.db_server.name
}

output "db_server_ip" {
  description = "Adresse IP du serveur de base de données"
  value       = virtualbox_vm.db_server.network_adapter[0].ipv4_address
}

output "ansible_inventory_hint" {
  description = "Information pour créer l'inventaire Ansible"
  value = <<-EOT
  Créez un fichier ansible/inventory.ini avec:

  [webservers]
  ${virtualbox_vm.web_server.name} ansible_host=${virtualbox_vm.web_server.network_adapter[0].ipv4_address}

  [databases]
  ${virtualbox_vm.db_server.name} ansible_host=${virtualbox_vm.db_server.network_adapter[0].ipv4_address}
  EOT
}
