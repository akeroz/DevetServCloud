# Déploiement de 2 VMs sur VirtualBox avec Terraform

Ce projet Terraform déploie automatiquement 2 machines virtuelles sur VirtualBox:
- **VM1**: Serveur Web (pour héberger WordPress)
- **VM2**: Serveur de Base de données (pour MySQL)

## Prérequis

### 1. Installer VirtualBox

Téléchargez et installez VirtualBox depuis: https://www.virtualbox.org/wiki/Downloads

```powershell
# Vérifier l'installation
VBoxManage --version
```

### 2. Installer Terraform

Téléchargez depuis: https://www.terraform.io/downloads

```powershell
# Vérifier l'installation
terraform version
```

### 3. Installer le provider VirtualBox pour Terraform

Le provider sera téléchargé automatiquement lors de `terraform init`.

## Configuration

### 1. Créer le fichier de configuration

```powershell
cd provider-virtualbox
cp terraform.tfvars.example terraform.tfvars
```

Modifiez `terraform.tfvars` selon vos besoins:

```hcl
project_name = "epsi-project"
vm_cpus      = 2
vm_memory    = "2048 mib"
```

## Déploiement

### 1. Initialiser Terraform

```powershell
terraform init
```

### 2. Voir le plan d'exécution

```powershell
terraform plan
```

### 3. Déployer les VMs

```powershell
terraform apply
```

Tapez `yes` pour confirmer.

### 4. Récupérer les informations des VMs

```powershell
# Afficher toutes les informations
terraform output

# Afficher l'IP du serveur web
terraform output web_server_ip

# Afficher l'IP du serveur de base de données
terraform output db_server_ip
```

## Connexion aux VMs

### Via VirtualBox Manager

1. Ouvrez VirtualBox
2. Vous verrez les 2 VMs: `epsi-project-web` et `epsi-project-db`
3. Double-cliquez pour ouvrir une console

### Via SSH (si configuré)

```powershell
# Connexion au serveur web
ssh vagrant@<IP_WEB_SERVER>

# Connexion au serveur de base de données
ssh vagrant@<IP_DB_SERVER>
```

Le mot de passe par défaut est généralement `vagrant`.

## Configuration réseau

Les VMs sont configurées avec 2 adaptateurs réseau:

1. **NAT**: Pour accéder à Internet
2. **Host-Only**: Pour communication entre VMs et avec l'hôte

### Trouver les IPs des VMs

```powershell
# Depuis VirtualBox Manager, sélectionnez la VM et allez dans Paramètres > Réseau
# Ou utilisez terraform output
terraform output web_server_ip
terraform output db_server_ip
```

## Étape suivante: Installation de WordPress avec Ansible

Une fois les VMs déployées, utilisez Ansible pour installer WordPress:

1. Notez les IPs des 2 VMs
2. Allez dans le dossier `ansible/`
3. Suivez le README d'Ansible pour déployer WordPress

## Gestion des VMs

### Voir l'état des VMs

```powershell
terraform show
```

### Arrêter les VMs

```powershell
# Via VirtualBox
VBoxManage controlvm epsi-project-web poweroff
VBoxManage controlvm epsi-project-db poweroff
```

### Détruire les VMs

**ATTENTION**: Ceci supprime définitivement les VMs!

```powershell
terraform destroy
```

## Dépannage

### Erreur "VirtualBox is not installed"

Assurez-vous que VirtualBox est installé et que `VBoxManage` est dans votre PATH.

```powershell
# Ajouter VirtualBox au PATH (Windows)
$env:PATH += ";C:\Program Files\Oracle\VirtualBox"
```

### Erreur de téléchargement de l'image

Si le téléchargement de l'image Ubuntu échoue, vous pouvez:

1. Télécharger manuellement l'image depuis https://app.vagrantup.com/ubuntu/boxes/focal64
2. Utiliser une autre image compatible VirtualBox

### Les VMs ne démarrent pas

Vérifiez que la virtualisation est activée dans le BIOS de votre machine.

```powershell
# Vérifier si la virtualisation est activée (Windows)
systeminfo | findstr /C:"Hyper-V"
```

## Ressources créées

- 2 VMs VirtualBox avec Ubuntu 20.04 LTS
- Configuration réseau NAT + Host-Only
- 2 CPUs et 2 Go de RAM par VM (configurable)

## Structure des fichiers

```
provider-virtualbox/
├── 00-provider.tf           # Configuration du provider VirtualBox
├── 01-vms.tf                # Définition des 2 VMs
├── variables.tf             # Variables configurables
├── outputs.tf               # Outputs après déploiement
├── terraform.tfvars.example # Exemple de configuration
├── .gitignore              # Fichiers à ignorer
└── README.md               # Ce fichier
```

## Alternative: Utiliser Vagrant

Si vous préférez utiliser Vagrant au lieu de Terraform, créez un `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.define "web" do |web|
    web.vm.hostname = "epsi-web"
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  config.vm.define "db" do |db|
    db.vm.hostname = "epsi-db"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
  end
end
```

Puis lancez: `vagrant up`

## Ressources utiles

- [Documentation VirtualBox](https://www.virtualbox.org/manual/)
- [Provider Terraform VirtualBox](https://registry.terraform.io/providers/terra-farm/virtualbox/latest/docs)
- [Vagrant Box Ubuntu](https://app.vagrantup.com/ubuntu/boxes/focal64)
