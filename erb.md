# Module ERB - Guide d'utilisation des templates ERB dans Puppet

## Introduction aux templates ERB

ERB (Embedded Ruby) est un système de template qui permet d'intégrer du code Ruby dans des documents texte. Dans le contexte de Puppet, ERB permet de créer des fichiers dynamiques qui varient en fonction des attributs du système cible ou d'autres variables définies par Puppet.

## Structure basique d'un template ERB

Les balises ERB principales sont:

- `<% code_ruby %>` - Exécute le code Ruby sans générer de sortie
- `<%= expression %>` - Évalue l'expression Ruby et insère le résultat dans le document
- `<%# commentaire %>` - Commentaire ERB (non visible dans le résultat final)
- `<% if condition -%>` - Le tiret supprime la nouvelle ligne (utile pour contrôler l'espacement)

## Variables dans les templates ERB

### Accès aux variables Puppet

Dans un template ERB, les variables Puppet sont disponibles de plusieurs façons:

1. **Variables de classe**: accessibles directement avec `@nom_variable` ou via un hash comme dans notre exemple avec `@template_vars['nom_variable']`

2. **Faits Puppet (facts)**: normalement accessibles via `@facts` dans le template

### Variables utilisées dans notre module

Dans notre module, nous passons plusieurs variables au template:

```puppet
$template_vars = {
  'os_family'    => $facts['os']['family'],
  'hostname'     => $facts['networking']['hostname'],
  'ipaddress'    => $facts['networking']['ip'],
  'current_time' => Timestamp()
}
```

Ces variables sont ensuite accessibles dans le template via `@template_vars['nom_variable']`.

## Structures conditionnelles

Les templates ERB vous permettent d'utiliser des structures conditionnelles pour générer différents contenus selon certaines conditions:

```erb
<% if @template_vars['os_family'] == 'Debian' -%>
Ce système est basé sur Debian.
<% else -%>
Ce système n'est PAS basé sur Debian.
<% end -%>
```

## Boucles et itérations

Vous pouvez également utiliser des boucles pour générer du contenu répétitif:

```erb
<% ['item1', 'item2', 'item3'].each do |item| -%>
- <%= item %>
<% end -%>
```

## Bonnes pratiques

1. **Commentez vos templates**: Utilisez `<%# commentaire %>` pour expliquer les sections complexes
2. **Contrôlez les espaces**: Utilisez le tiret (`-%>`) pour éviter les lignes vides superflues
3. **Gardez la logique simple**: Mettez la logique complexe dans le manifeste Puppet plutôt que dans le template
4. **Validez vos templates**: Vérifiez que le fichier généré est valide avec des tests appropriés

## Exemple complet

Notre module utilise un template qui crée différents fichiers selon le système d'exploitation:

```erb
<%# Template pour générer un fichier en fonction du système d'exploitation %>
Ce fichier a été généré par Puppet le <%= @template_vars['current_time'] %>

Information sur le système:
------------------------
Hostname: <%= @template_vars['hostname'] %>
Adresse IP: <%= @template_vars['ipaddress'] %>
Famille OS: <%= @template_vars['os_family'] %>

<% if @template_vars['os_family'] == 'Debian' -%>
Ce système est basé sur Debian.
Le fichier a été créé dans /opt/data666/coucou.deb
<% else -%>
Ce système n'est PAS basé sur Debian.
Le fichier a été créé dans /home/sderkaoui/jesuispasdebian.deb
<% end -%>

Fichier généré automatiquement, merci de ne pas modifier manuellement.
```

## Utilisation dans le manifeste Puppet

Pour utiliser un template ERB dans un manifeste Puppet:

```puppet
file { $filepath:
  ensure  => present,
  content => template('erb/test.erb'),  # erb est le nom du module, test.erb est le chemin relatif dans /templates
  # ... autres attributs ...
}
```

## Ressources supplémentaires

- [Documentation officielle Puppet sur les templates](https://puppet.com/docs/puppet/latest/lang_template_erb.html)
- [Tutoriel ERB de Ruby](https://docs.ruby-lang.org/en/master/ERB.html)
