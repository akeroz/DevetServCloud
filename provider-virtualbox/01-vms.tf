# Configuration des 2 machines virtuelles VirtualBox

# VM 1: Serveur Web (pour WordPress)
resource "virtualbox_vm" "web_server" {
  name   = "${var.project_name}-web"
  image  = var.vm_image
  cpus   = var.vm_cpus
  memory = var.vm_memory

  network_adapter {
    type           = "nat"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }

  # Configuration réseau supplémentaire pour accès depuis l'hôte
  network_adapter {
    type = "hostonly"
  }
}

# VM 2: Serveur de base de données (pour MySQL)
resource "virtualbox_vm" "db_server" {
  name   = "${var.project_name}-db"
  image  = var.vm_image
  cpus   = var.vm_cpus
  memory = var.vm_memory

  network_adapter {
    type           = "nat"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }

  # Configuration réseau supplémentaire pour accès depuis l'hôte
  network_adapter {
    type = "hostonly"
  }
}
