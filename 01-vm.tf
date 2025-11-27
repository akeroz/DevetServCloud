# Contient la définition des deux dépôts GitHub

resource "github_repository" "repo_projet_iaas" {
  name                   = "projet-iaas-caas-paas"
  description            = "Dépôt pour le projet de présentation des services Cloud."
  visibility             = "private"
  auto_init              = true 
}

resource "github_repository" "repo_automation_terraform" {
  name                   = "automation-terraform-ci"
  description            = "Dépôt pour les fichiers de configuration Terraform et CI/CD."
  visibility             = "public"
  has_issues             = true
}