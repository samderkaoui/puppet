# Module erb - Utilisation de templates ERB pour générer des fichiers en fonction du système
class erb {
  # On a besoin du module common pour le dossier /opt/data666
  require common

  # Déterminer le chemin du fichier en fonction du système d'exploitation
  $os_family = $facts['os']['family']
  
  if $os_family == 'Debian' {
    $filepath = '/opt/data666/coucou.deb'
  } else {
    $filepath = '/home/sderkaoui/jesuispasdebian.deb'
  }
  
  # Variables à passer au template
  $template_vars = {
    'os_family'    => $os_family,
    'hostname'     => $facts['networking']['hostname'],
    'ipaddress'    => $facts['networking']['ip'],
    'current_time' => Timestamp()
  }
  
  # Créer le fichier à partir du template
  file { $filepath:
    ensure  => present,
    content => template('erb/test.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
