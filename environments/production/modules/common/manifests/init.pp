# Classe common - Fonctionnalités communes partagées entre nodes
class common {
  
  # Créer un dossier avec des permissions 777
  file { '/opt/data666':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }
}
