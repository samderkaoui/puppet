# nodes.pp - Définition des nodes spécifiques
# Ce fichier contient les configurations spécifiques à chaque node

node 'agent01' {
#  include common
  include vpgfile
  include erb
}

# Deuxième node qui n'est pas définis pour tester defaults
node 'node2.example.com' {
  include common
}
