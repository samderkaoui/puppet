# Guide complet de Puppet

## Introduction

Puppet est un outil de gestion de configuration qui permet d'automatiser l'installation, la configuration et la gestion des logiciels sur des serveurs. Il utilise un langage déclaratif pour décrire l'état souhaité d'un système, puis s'assure que cet état est maintenu.

## Architecture de Puppet

Puppet fonctionne selon un modèle client-serveur :

- **Puppet Master** : Serveur central qui stocke les configurations et les distribue aux nodes
- **Puppet Agent** : Client installé sur les machines à gérer, qui applique les configurations

## Structure d'un projet Puppet

```
puppet-test/
├── environments/            # Environnements Puppet (production, staging, dev)
│   └── production/
│       ├── manifests/       # Manifestes spécifiques à l'environnement
│       ├── modules/         # Modules spécifiques à l'environnement
│       └── data/            # Données Hiera spécifiques à l'environnement
├── manifests/               # Manifestes globaux
│   └── site.pp              # Point d'entrée principal
└── modules/                 # Modules globaux
    └── nginx/
        ├── manifests/       # Manifestes du module
        │   └── init.pp      # Définition principale du module
        ├── files/           # Fichiers statiques
        └── templates/       # Templates (ERB, EPP)
```

## Concepts clés

### Manifestes

Les manifestes (`.pp`) sont des fichiers contenant du code Puppet qui décrivent l'état souhaité d'un système. Le manifeste principal est généralement `site.pp`.

### Classes

Les classes sont des collections nommées de ressources qui peuvent être appliquées comme une unité.

```puppet
# Définition d'une classe
class apache {
  package { 'apache2':
    ensure => installed,
  }
  
  service { 'apache2':
    ensure    => running,
    enable    => true,
    require   => Package['apache2'],
  }
}

# Utilisation d'une classe
include apache
```

### Modules

Un module est un ensemble de manifestes, fichiers, templates et autres ressources regroupés de manière structurée. Les modules encapsulent une fonctionnalité spécifique (comme l'installation et la configuration d'un service).

Structure d'un module :
- `manifests/` : Contient les classes et définitions
- `files/` : Fichiers statiques qui peuvent être copiés sur les nodes
- `templates/` : Templates pour générer des fichiers dynamiques
- `lib/` : Code Ruby personnalisé (facts, functions, etc.)

### Ressources

Les ressources sont les blocs de construction fondamentaux de Puppet. Chaque ressource représente un aspect du système à gérer.

Types de ressources courants :
- `package` : Gère les paquets logiciels
- `file` : Gère les fichiers et répertoires
- `service` : Gère les services
- `user` : Gère les utilisateurs
- `exec` : Exécute des commandes

Syntaxe générale :
```puppet
type { 'title':
  attribute => value,
  ...
}
```

Exemple :
```puppet
file { '/etc/myapp/config.conf':
  ensure  => present,
  content => template('myapp/config.conf.erb'),
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
}
```

### Notify et Subscribe

Ces attributs permettent de définir des dépendances et des déclencheurs entre ressources :

- `notify` : Indique qu'une ressource doit notifier une autre ressource lorsqu'elle change
- `subscribe` : Indique qu'une ressource doit réagir aux changements d'une autre ressource

```puppet
file { '/etc/nginx/nginx.conf':
  ensure  => present,
  source  => 'puppet:///modules/nginx/nginx.conf',
  notify  => Service['nginx'],
}

service { 'nginx':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/nginx/nginx.conf'],
}
```

### Variables et Facts

- **Variables** : Permettent de stocker et réutiliser des valeurs
- **Facts** : Informations collectées automatiquement sur les nodes (OS, adresse IP, etc.)

```puppet
$app_port = 8080

# Utilisation d'un fact
if $facts['os']['family'] == 'Debian' {
  package { 'apache2': ensure => installed }
} elsif $facts['os']['family'] == 'RedHat' {
  package { 'httpd': ensure => installed }
}
```

### Conditionnels

Puppet prend en charge plusieurs structures conditionnelles :

```puppet
# If-else
if $facts['os']['family'] == 'Debian' {
  # code pour Debian
} elsif $facts['os']['family'] == 'RedHat' {
  # code pour RedHat
} else {
  # code par défaut
}

# Case
case $facts['os']['family'] {
  'Debian': { # code pour Debian }
  'RedHat': { # code pour RedHat }
  default: { # code par défaut }
}

# Selector
$package_name = $facts['os']['family'] ? {
  'Debian' => 'apache2',
  'RedHat' => 'httpd',
  default  => 'apache',
}
```

### Hiera

Hiera est un système de stockage de données hiérarchique qui permet de séparer les données de la logique dans Puppet.

```yaml
# data/common.yaml
---
nginx::port: 80
nginx::workers: 4
```

```puppet
# Utilisation des données Hiera
class nginx (
  Integer $port = lookup('nginx::port'),
  Integer $workers = lookup('nginx::workers'),
) {
  # code utilisant $port et $workers
}
```

## Exemple complet

Dans notre projet, nous avons configuré :

1. Un manifeste principal (`site.pp`) qui définit un node et inclut notre module nginx
2. Un module nginx avec une classe qui :
   - Installe le paquet nginx
   - Configure le service nginx pour qu'il démarre automatiquement
   - Crée un fichier de configuration de base

## Workflow Puppet

1. Le Puppet Agent envoie des facts au Puppet Master
2. Le Puppet Master compile un catalogue basé sur ces facts et les manifestes
3. Le Puppet Agent applique le catalogue sur le node
4. Le Puppet Agent rapporte les résultats au Puppet Master

## Configuration Master-Node

### Sur le Master

1. Installer Puppet Server : `apt-get install puppetserver`
2. Configurer `/etc/puppetlabs/puppet/puppet.conf` :
   ```ini
   [main]
   certname = puppet.example.com
   server = puppet.example.com
   environment = production
   runinterval = 1h
   ```
3. Démarrer le service : `systemctl start puppetserver`

### Sur le Node

1. Installer Puppet Agent : `apt-get install puppet-agent`
2. Configurer `/etc/puppetlabs/puppet/puppet.conf` :
   ```ini
   [main]
   certname = node.example.com
   server = puppet.example.com
   environment = production
   runinterval = 1h
   ```
3. Démarrer l'agent : `systemctl start puppet`
4. Exécuter manuellement : `puppet agent -t`

### Gestion des certificats

Sur le Master :
```bash
puppetserver ca list
puppetserver ca sign --certname node.example.com
```

## Bonnes pratiques

1. Organiser le code en modules réutilisables
2. Séparer les données (Hiera) du code
3. Utiliser le contrôle de version (Git)
4. Tester les manifestes avant déploiement
5. Utiliser des environnements (production, staging, development)
6. Documenter le code
7. Suivre les principes DRY (Don't Repeat Yourself)

## Commandes utiles

- `puppet agent -t` : Exécuter l'agent Puppet en mode test (verbose)
- `puppet apply manifest.pp` : Appliquer un manifeste localement
- `puppet module list` : Lister les modules installés
- `puppet module install <module>` : Installer un module depuis Forge
- `puppet parser validate manifest.pp` : Valider la syntaxe d'un manifeste
- `puppet lookup <key>` : Rechercher une valeur dans Hiera
