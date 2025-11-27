# Contient la déclaration du fournisseur GitHub

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0" 
    }
  }
}

# Configuration du fournisseur utilisant GITHUB_TOKEN
provider "github" {}