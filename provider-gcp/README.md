# Déploiement d'une VM Compute Engine sur GCP avec Terraform

Ce projet Terraform déploie une infrastructure complète sur Google Cloud Platform comprenant:
- Un VPC (Virtual Private Cloud) personnalisé
- Un sous-réseau avec configuration des logs de flux
- Des règles de pare-feu (SSH, HTTP/HTTPS, trafic interne)
- Une machine virtuelle Compute Engine avec IP publique statique

## Prérequis

### 1. Installer Terraform
```bash
# Télécharger depuis https://www.terraform.io/downloads
# Vérifier l'installation
terraform version
```

### 2. Installer et configurer Google Cloud SDK
```bash
# Télécharger depuis https://cloud.google.com/sdk/docs/install
# Vérifier l'installation
gcloud version
```

### 3. Authentification GCP

**POUR CE PROJET: Utiliser le Service Account fourni (DEJA CONFIGURE)**

Le fichier `gcp-service-account.json` contient déjà vos credentials. Définissez simplement la variable d'environnement:

```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="$PWD\gcp-service-account.json"

# Windows CMD
set GOOGLE_APPLICATION_CREDENTIALS=%CD%\gcp-service-account.json

# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/gcp-service-account.json"
```

Votre projet ID est: `playground-s-11-c0729686`

---

**Autres méthodes d'authentification (si nécessaire):**

<details>
<summary>Option A: Utiliser gcloud</summary>

```bash
# Se connecter à GCP
gcloud auth login

# Configurer les credentials pour Terraform
gcloud auth application-default login

# Définir votre projet par défaut
gcloud config set project VOTRE_PROJECT_ID
```
</details>

<details>
<summary>Option B: Créer un nouveau Service Account</summary>

```bash
# Créer un service account
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"

# Donner les permissions nécessaires
gcloud projects add-iam-policy-binding VOTRE_PROJECT_ID \
  --member="serviceAccount:terraform-sa@VOTRE_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding VOTRE_PROJECT_ID \
  --member="serviceAccount:terraform-sa@VOTRE_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Créer et télécharger la clé
gcloud iam service-accounts keys create ~/gcp-terraform-key.json \
  --iam-account=terraform-sa@VOTRE_PROJECT_ID.iam.gserviceaccount.com

# Définir la variable d'environnement
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-terraform-key.json
```
</details>

## Configuration

### 1. Créer un fichier terraform.tfvars

Créez un fichier `terraform.tfvars` avec vos valeurs:

```hcl
# Configuration obligatoire
project_id   = "votre-project-id-gcp"
project_name = "mon-projet"

# Configuration optionnelle
region = "europe-west1"
zone   = "europe-west1-b"

# Configuration réseau
subnet_cidr = "10.0.1.0/24"

# Configuration VM
machine_type      = "e2-micro"  # Niveau gratuit GCP
boot_disk_image   = "debian-cloud/debian-11"
boot_disk_size    = 10
instance_tags     = ["ssh-enabled", "web-server"]

# SSH (optionnel - générez une clé SSH si nécessaire)
ssh_user       = "votre-username"
ssh_public_key = "ssh-rsa AAAA... votre-email@example.com"

# Sécurité - Limiter l'accès SSH à votre IP
allowed_ssh_sources = ["VOTRE_IP/32"]  # Remplacer par votre IP publique

# Environnement
environment = "dev"
```

### 2. Générer une clé SSH (si nécessaire)

```bash
# Générer une paire de clés SSH
ssh-keygen -t rsa -b 4096 -C "votre-email@example.com" -f ~/.ssh/gcp-terraform-key

# Afficher la clé publique pour la copier dans terraform.tfvars
cat ~/.ssh/gcp-terraform-key.pub
```

### 3. Obtenir votre IP publique

```bash
# Linux/Mac
curl ifconfig.me

# Windows PowerShell
(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
```

## Utilisation

### 1. Initialiser Terraform

```bash
cd provider-gcp
terraform init
```

Cette commande télécharge le provider Google Cloud.

### 2. Vérifier le plan d'exécution

```bash
terraform plan
```

Cette commande affiche les ressources qui seront créées sans les créer réellement.

### 3. Déployer l'infrastructure

```bash
terraform apply
```

Terraform vous demandera confirmation avant de créer les ressources. Tapez `yes` pour confiruer.

### 4. Voir les informations de connexion

Après le déploiement, Terraform affichera les outputs importants:

```bash
# Afficher tous les outputs
terraform output

# Afficher un output spécifique
terraform output vm_external_ip
terraform output ssh_connection_command
```

### 5. Se connecter à la VM

```bash
# Via la commande SSH affichée dans les outputs
ssh votre-username@IP_PUBLIQUE -i ~/.ssh/gcp-terraform-key

# Ou via gcloud
gcloud compute ssh mon-projet-vm --zone=europe-west1-b
```

### 6. Vérifier le serveur web

Si le script de démarrage a installé nginx:
```bash
# Dans votre navigateur ou via curl
curl http://IP_PUBLIQUE
```

## Gestion de l'infrastructure

### Modifier l'infrastructure

1. Modifiez les fichiers `.tf` ou `terraform.tfvars`
2. Vérifiez les changements: `terraform plan`
3. Appliquez les changements: `terraform apply`

### Détruire l'infrastructure

**ATTENTION: Cette commande supprime toutes les ressources créées**

```bash
terraform destroy
```

### Voir l'état actuel

```bash
# Afficher toutes les ressources
terraform state list

# Afficher les détails d'une ressource
terraform state show google_compute_instance.vm_instance
```

## Structure des fichiers

```
provider-gcp/
├── 00-provider.tf    # Configuration du provider GCP
├── 01-network.tf     # VPC, sous-réseau, règles de pare-feu
├── 02-compute.tf     # Instance Compute Engine
├── variables.tf      # Définition des variables
├── outputs.tf        # Outputs affichés après le déploiement
├── terraform.tfvars  # Vos valeurs de configuration (à créer)
└── README.md         # Ce fichier
```

## Ressources créées

1. **VPC Network**: Réseau privé virtuel personnalisé
2. **Subnet**: Sous-réseau dans la région spécifiée
3. **Firewall Rules**:
   - SSH (port 22) depuis les IPs autorisées
   - HTTP/HTTPS (ports 80, 443) depuis Internet
   - Trafic interne au VPC
4. **Static IP**: Adresse IP publique statique
5. **Compute Instance**: Machine virtuelle avec:
   - Type de machine configurable
   - Disque de démarrage avec image Linux
   - Script de démarrage (installation nginx)
   - Clé SSH pour l'accès

## Coûts

- **e2-micro**: Généralement éligible au niveau gratuit GCP
- **IP statique**: Gratuite si attachée à une VM en cours d'exécution
- **Trafic réseau**: Selon l'utilisation
- **Stockage disque**: Selon la taille et le type

Consultez la [calculatrice de prix GCP](https://cloud.google.com/products/calculator) pour estimer vos coûts.

## Dépannage

### Erreur d'authentification
```bash
gcloud auth application-default login
```

### Erreur de quota ou de permissions
Vérifiez que:
- Les APIs nécessaires sont activées (Compute Engine API)
- Votre compte a les permissions suffisantes
- Votre projet n'a pas atteint ses quotas

### Activer les APIs nécessaires
```bash
gcloud services enable compute.googleapis.com
```

### Voir les logs de la VM
```bash
gcloud compute instances get-serial-port-output mon-projet-vm --zone=europe-west1-b
```

## Ressources utiles

- [Documentation Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Documentation GCP Compute Engine](https://cloud.google.com/compute/docs)
- [Images disponibles sur GCP](https://cloud.google.com/compute/docs/images)
- [Types de machines](https://cloud.google.com/compute/docs/machine-types)

## Sécurité - Bonnes pratiques

1. **Limitez l'accès SSH**: Ne pas utiliser `0.0.0.0/0`, utilisez votre IP spécifique
2. **Utilisez des clés SSH fortes**: RSA 4096 bits minimum
3. **Activez les logs**: Les logs de flux VPC sont activés par défaut
4. **Mettez à jour régulièrement**: Gardez vos images et packages à jour
5. **Ne commitez jamais**: `terraform.tfvars` et les clés privées dans git

Ajoutez à votre `.gitignore`:
```
*.tfvars
*.tfstate
*.tfstate.backup
.terraform/
*.pem
*.key
```
