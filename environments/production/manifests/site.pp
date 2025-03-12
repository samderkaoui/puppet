# Site.pp - Manifeste principal
# Ce fichier est le point d'entrée principal de Puppet

# Définition des nodes
node 'agent01' {
  include common
  include vpgfile
  include erb
}

# Deuxième node qui ne fait que créer le dossier
#node 'node2.example.com' {
#  include common
#}

# Node par défaut (utilisé si aucun node spécifique ne correspond)
node default {
  notify { 'Default node message':
    message => "Ce node n'est pas explicitement défini dans Puppet.",
  }
}
