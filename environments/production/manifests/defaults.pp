# defaults.pp - Configuration par défaut
# Ce fichier contient la configuration pour les nodes non explicitement définis

node default {
  # Inclure la classe common pour les nodes par défaut aussi
  include common
  
  notify { 'Default node message':
    message => "Ce node n'est pas explicitement défini dans Puppet.",
  }
}
