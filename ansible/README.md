# Playbook Ansible pour installer WordPress

Ce playbook Ansible installe automatiquement WordPress sur 2 VMs:
- **VM1 (webservers)**: Serveur Web avec Apache, PHP et WordPress
- **VM2 (databases)**: Serveur MySQL pour la base de données WordPress

## Prérequis

### 1. Installer Ansible

**Windows (via WSL ou Git Bash)**:
```bash
# Avec pip
pip install ansible

# Vérifier l'installation
ansible --version
```

**Linux/Mac**:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# Mac
brew install ansible
```

### 2. Avoir 2 VMs déployées

Les VMs doivent être accessibles via SSH. Vous pouvez les créer avec:
- Terraform (voir `provider-virtualbox/`)
- VirtualBox manuellement
- Vagrant
- VMware

### 3. Configurer l'accès SSH

Assurez-vous de pouvoir vous connecter aux VMs via SSH:

```bash
ssh vagrant@<IP_VM_WEB>
ssh vagrant@<IP_VM_DB>
```

## Configuration

### 1. Créer l'inventaire Ansible

Copiez le fichier d'exemple et modifiez-le avec vos IPs:

```bash
cd ansible
cp inventory.ini.example inventory.ini
```

Éditez `inventory.ini` avec les vraies IPs de vos VMs:

```ini
[webservers]
epsi-project-web ansible_host=192.168.56.10 ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa

[databases]
epsi-project-db ansible_host=192.168.56.11 ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 2. Tester la connexion

```bash
# Tester la connexion à toutes les VMs
ansible all -m ping

# Devrait afficher:
# epsi-project-web | SUCCESS => { ... "ping": "pong" ... }
# epsi-project-db | SUCCESS => { ... "ping": "pong" ... }
```

## Déploiement de WordPress

### 1. Lancer le playbook

```bash
ansible-playbook playbook-wordpress.yml
```

Le playbook va:
1. Installer et configurer MySQL sur la VM database
2. Créer la base de données WordPress
3. Installer Apache et PHP sur la VM webserver
4. Télécharger et configurer WordPress
5. Configurer Apache pour servir WordPress

### 2. Accéder à WordPress

Une fois le playbook terminé, ouvrez votre navigateur:

```
http://<IP_VM_WEB>/
```

Vous devriez voir la page d'installation de WordPress.

### 3. Installer WordPress

Suivez l'assistant d'installation WordPress:

1. **Langue**: Sélectionnez le français
2. **Titre du site**: Nom de votre site
3. **Nom d'utilisateur**: admin (changez-le!)
4. **Mot de passe**: Choisissez un mot de passe fort
5. **Email**: Votre email
6. Cliquez sur "Installer WordPress"

## Configuration avancée

### Modifier les mots de passe de la base de données

Éditez `playbook-wordpress.yml` et modifiez ces variables:

```yaml
vars:
  mysql_root_password: "VotreMotDePasseRoot"
  wordpress_db_name: "wordpress"
  wordpress_db_user: "wpuser"
  wordpress_db_password: "VotreMotDePasseWP"
```

### Installer une autre version de WordPress

Par défaut, le playbook installe la dernière version. Pour une version spécifique:

```yaml
vars:
  wordpress_version: "wordpress-6.4"
```

### Sécuriser WordPress

Le fichier `wp-config.php` est généré avec des clés par défaut. Pour plus de sécurité:

1. Allez sur: https://api.wordpress.org/secret-key/1.1/salt/
2. Copiez les clés générées
3. Éditez `templates/wp-config.php.j2` et remplacez les clés

## Vérification

### Vérifier que les services fonctionnent

```bash
# Sur la VM Web
ansible webservers -a "systemctl status apache2"
ansible webservers -a "systemctl status php7.4-fpm"

# Sur la VM Database
ansible databases -a "systemctl status mysql"
```

### Tester la connexion à la base de données

```bash
# Depuis la VM Web, tester la connexion MySQL
ansible webservers -m shell -a "mysql -h <IP_VM_DB> -u wpuser -pWpPassword123! wordpress -e 'SHOW TABLES;'"
```

### Voir les logs

```bash
# Logs Apache
ansible webservers -a "tail -n 50 /var/log/apache2/wordpress-error.log"

# Logs MySQL
ansible databases -a "tail -n 50 /var/log/mysql/error.log"
```

## Structure du playbook

```
ansible/
├── playbook-wordpress.yml       # Playbook principal
├── templates/
│   ├── wp-config.php.j2        # Template de configuration WordPress
│   └── wordpress.conf.j2       # Template VirtualHost Apache
├── inventory.ini.example       # Exemple d'inventaire
├── ansible.cfg                 # Configuration Ansible
├── .gitignore                 # Fichiers à ignorer
└── README.md                  # Ce fichier
```

## Playbooks alternatifs

### Playbook pour installer Nginx au lieu d'Apache

Créez `playbook-wordpress-nginx.yml` pour utiliser Nginx + PHP-FPM au lieu d'Apache.

### Playbook pour un simple serveur web

Créez `playbook-simple-web.yml`:

```yaml
---
- name: Installer un serveur web simple
  hosts: webservers
  become: yes
  tasks:
    - name: Installer Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Démarrer Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

## Dépannage

### Erreur "Failed to connect to the host"

Vérifiez:
- Les IPs dans `inventory.ini` sont correctes
- Vous pouvez ping les VMs: `ping <IP_VM>`
- SSH fonctionne: `ssh vagrant@<IP_VM>`
- Le firewall n'est pas bloqué

### Erreur "Permission denied (publickey)"

Configurez l'authentification SSH:

```bash
# Copier votre clé publique sur les VMs
ssh-copy-id vagrant@<IP_VM_WEB>
ssh-copy-id vagrant@<IP_VM_DB>
```

### Erreur "mysql_db module requires PyMySQL"

Installez PyMySQL sur la VM:

```bash
ansible databases -m apt -a "name=python3-pymysql state=present" --become
```

### WordPress affiche "Error establishing a database connection"

Vérifiez:
1. MySQL est démarré sur la VM database
2. Le pare-feu autorise le port 3306
3. Les credentials dans `wp-config.php` sont corrects

```bash
# Autoriser MySQL sur le pare-feu
ansible databases -m ufw -a "rule=allow port=3306" --become
```

## Ressources utiles

- [Documentation Ansible](https://docs.ansible.com/)
- [WordPress Installation Guide](https://wordpress.org/support/article/how-to-install-wordpress/)
- [Ansible MySQL Module](https://docs.ansible.com/ansible/latest/collections/community/mysql/index.html)
