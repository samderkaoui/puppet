# defaults.pp - Configuration par défaut
# Ce fichier contient la configuration pour les nodes non explicitement définis

node default {
  # Inclure la classe common pour les nodes par défaut aussi
  include common
  
  notify { 'Default node message':
    message => "Ce node n'est pas explicitement défini dans Puppet.",
  }
}



#defaults.pp avec node default { ... } :
#S'applique UNIQUEMENT aux nodes qui n'ont PAS de définition spécifique dans nodes.pp
#Ne s'applique PAS aux nodes explicitement définis (comme 'agent01' ou 'node2.example.com')
#C'est un "filet de sécurité" pour les nodes inconnus ou non configurés
#globals.pp (niveau supérieur, sans node) :
#S'applique à TOUS les nodes, qu'ils soient définis explicitement ou non
#Exécuté pour chaque node, sans exception
#Établit une configuration de base universelle
