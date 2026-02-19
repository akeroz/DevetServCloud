# Guide de démarrage rapide - CloudGuru

Ce guide vous permet de déployer rapidement votre VM sur GCP en 3 étapes.

## Etape 1: Configurer l'authentification

Ouvrez PowerShell dans le dossier `provider-gcp` et exécutez:

```powershell
# Définir la variable d'environnement pour les credentials
$env:GOOGLE_APPLICATION_CREDENTIALS="$PWD\gcp-service-account.json"

# Vérifier que le fichier existe
Test-Path .\gcp-service-account.json
```

Vous devriez voir `True` s'afficher.

## Etape 2: Initialiser et déployer

```powershell
# Installer Terraform si ce n'est pas déjà fait
# Téléchargez depuis: https://www.terraform.io/downloads

# Initialiser Terraform (télécharge les providers)
terraform init

# Voir ce qui va être créé
terraform plan

# Créer l'infrastructure
terraform apply
```

Terraform vous demandera de confirmer. Tapez `yes` et appuyez sur Entrée.

## Etape 3: Récupérer les informations de connexion

Une fois le déploiement terminé, récupérez l'IP de votre VM:

```powershell
# Afficher l'IP publique de la VM
terraform output vm_external_ip

# Afficher la commande SSH complète
terraform output ssh_connection_command

# Afficher l'URL du serveur web
terraform output web_url
```

## Se connecter à la VM

### Option 1: Via gcloud (recommandé)

```powershell
gcloud compute ssh cloudguru-demo-vm --zone=europe-west1-b --project=playground-s-11-c0729686
```

### Option 2: Via SSH standard

Si vous avez configuré une clé SSH dans `terraform.tfvars`:

```powershell
ssh student@<IP_PUBLIQUE>
```

## Tester le serveur web

Ouvrez votre navigateur et allez sur `http://<IP_PUBLIQUE>`

Vous devriez voir une page avec "VM déployée avec Terraform sur GCP".

## Détruire l'infrastructure

**ATTENTION:** Cette commande supprime toutes les ressources!

```powershell
terraform destroy
```

Confirmez avec `yes`.

## En cas de problème

### Erreur d'authentification

Vérifiez que la variable d'environnement est bien définie:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS
```

Elle devrait afficher le chemin vers `gcp-service-account.json`.

### Erreur de permissions ou d'API

Activez l'API Compute Engine si nécessaire:

```powershell
gcloud services enable compute.googleapis.com --project=playground-s-11-c0729686
```

### Voir les logs détaillés

```powershell
# Activer les logs détaillés
$env:TF_LOG="DEBUG"
terraform plan
```

## Ressources créées

- 1 VPC personnalisé
- 1 sous-réseau (10.0.1.0/24)
- 3 règles de pare-feu (SSH, HTTP/HTTPS, interne)
- 1 IP publique statique
- 1 VM Compute Engine (e2-micro)

## Documentation complète

Consultez [README.md](README.md) pour plus de détails sur la configuration et la personnalisation.
