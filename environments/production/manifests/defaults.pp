# defaults.pp - Configuration par défaut
# Ce fichier contient la configuration pour les nodes non explicitement définis

node default {
  notify { 'Default node message':
    message => "Ce node n'est pas explicitement défini dans Puppet.",
  }
}
