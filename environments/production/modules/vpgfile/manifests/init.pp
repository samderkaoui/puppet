# Classe vpgfile - Création d'un fichier dans /opt/data
class vpgfile {
  # Vérifie que le dossier /opt/data existe
  # (utilise le module common indirectement)
  require common

  # Crée le fichier /opt/data/VPG-TEST
  file { '/opt/data666/VPG-TEST':
    ensure  => present,
    source  => 'puppet:///modules/vpgfile/VPG-TEST',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    # Ce fichier dépend de la création préalable du dossier /opt/data
  }
}
