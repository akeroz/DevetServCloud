# Configuration du provider VirtualBox pour Terraform

terraform {
  required_version = ">= 1.0"

  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "~> 0.2"
    }
  }
}

# Le provider VirtualBox n'a pas besoin de configuration spécifique
# Il utilise l'installation VirtualBox locale
provider "virtualbox" {}
