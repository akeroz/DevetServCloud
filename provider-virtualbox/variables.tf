# Variables pour la configuration VirtualBox

variable "project_name" {
  description = "Nom du projet (utilisé pour nommer les VMs)"
  type        = string
  default     = "epsi-project"
}

variable "vm_image" {
  description = "URL de l'image Ubuntu à utiliser pour les VMs"
  type        = string
  default     = "https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20240821.0.0/providers/virtualbox/amd64/vagrant.box"
}

variable "vm_cpus" {
  description = "Nombre de CPUs par VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Mémoire RAM par VM en MB"
  type        = string
  default     = "2048 mib"
}
