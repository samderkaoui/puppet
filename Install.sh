https://shape.host/resources/puppet-server-and-agent-installation-guide-debian-11
https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/puppet/introduction/


# Prérequis ET debian 11
# sudo passwd sderkaoui

sudo apt update && sudo apt install -y openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

sudo apt install tree -y
sudo apt install -y wget

echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config




# Step 1: Set up FQDN on the Puppet Server
sudo hostnamectl set-hostname puppet-server.localdomain.lan

# Step 2: Set up FQDN on the Puppet Agent
sudo hostnamectl set-hostname agent.localdomain.lan



# Step 3: Edit the /etc/hosts File
echo "198.19.249.148 puppet puppet-server.localdomain.lan" | sudo tee -a /etc/hosts
echo "198.19.249.132 agent.localdomain.lan" | sudo tee -a /etc/hosts


# Step 4: Verify Connectivity
ping puppet-server.localdomain.lan -c 3
ping agent.localdomain.lan -c 3


# Step 5: Adding Puppet Repository
wget https://apt.puppet.com/puppet7-release-bullseye.deb
sudo dpkg -i puppet7-release-bullseye.deb
sudo apt update -y

# Step 6: Installing Puppet Server
sudo apt install puppetserver -y


# Step 7: Configure Puppet Server

# Configure Environment Variables

source /etc/profile.d/puppet-agent.sh
echo "export PATH=$PATH:/opt/puppetlabs/bin/" | tee -a ~/.bashrc
source ~/.bashrc


# Step 8: Configure Puppet Server Memory Allocation

- sudo vim /etc/default/puppetserver

JAVA_ARGS="-Xms1g -Xmx1g"

sudo systemctl daemon-reload
sudo systemctl enable --now puppetserver
sudo systemctl status puppetserver



# Step 9: Firewall

sudo ufw allow from 192.168.5.0/24 to any proto tcp port 8140
sudo ufw status




# Step 10: Installing and Configuring Puppet Agent
sudo apt install -y puppet-agent
# Set Puppet Server FQDN
sudo /opt/puppetlabs/bin/puppet config set server puppet-server.localdomain.lan --section agent
# Set Certificate Authority Server
sudo /opt/puppetlabs/bin/puppet config set ca_server puppet-server.localdomain.lan --section agent

# restart
sudo systemctl restart puppet
sudo systemctl status puppet



# Step 11: Register Puppet Agent to Puppet Server
# verify connectivity
ping puppet-server.localdomain.lan -c 3

# Set Puppet Server FQDN
sudo /opt/puppetlabs/bin/puppet config set server puppet-server.localdomain.lan --section agent
# Set Certificate Authority Server
sudo /opt/puppetlabs/bin/puppet config set ca_server puppet-server.localdomain.lan --section agent




sudo systemctl restart puppet


# Step 12: Certificate Signing

sudo /opt/puppetlabs/bin/puppetserver ca list --all
sudo /opt/puppetlabs/bin/puppetserver ca sign --certname agent.localdomain.lan









/etc/puppetlabs/puppet/puppet.conf
















# modification certname:


sudo systemctl stop puppet
echo "certname = agent01" | sudo tee -a /etc/puppetlabs/puppet/puppet.conf
echo "environment = production" | sudo tee -a /etc/puppetlabs/puppet/puppet.conf
sudo systemctl restart puppet
cat /etc/puppetlabs/puppet/puppet.conf


- sur server puppet : sudo /opt/puppetlabs/bin/puppetserver ca sign --certname agent01
sudo /opt/puppetlabs/bin/puppet agent -t

- sur serveur puppet :
sudo /opt/puppetlabs/bin/puppetserver ca clean --certname agent.localdomain.lan



# Commande pour lancer puppet agent
sudo /opt/puppetlabs/bin/puppet agent -t















Confluence VPG :


Installation d’un serveur Puppet en version 8 sur OS Debian (11.9 stable)

Dans le cas où il s’agisse d’une machine livrée depuis un template plus ancien, enlever le repo ancien:

apt-get remove --purge puppet-agent puppet6-release

Install

Inspiré par diverses sources:

# https://libremaster.com/comment-installer-un-serveur-puppet-foreman-debian/
# https://shape.host/resources/puppet-server-and-agent-installation-guide-debian-11

Ajouter le repo v8:

wget https://apt.puppet.com/puppet8-release-bullseye.deb
dpkg -i puppet8-release-bullseye.deb
apt-get update

Install à proprement parler:

apt-get install puppetserver puppetdb puppetdb-termini
systemctl enable puppetserver

Adapter l’allocation mémoire selon la quantité de RAM dans /etc/default/puppetserver :

JAVA_ARGS="-Xms1g -Xmx1g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"



Exemple du fichier /etc/puppetlabs/puppet/puppet.conf :

[server]
vardir = /opt/puppetlabs/server/data/puppetserver
logdir = /var/log/puppetlabs/puppetserver
rundir = /var/run/puppetlabs/puppetserver
pidfile = /var/run/puppetlabs/puppetserver/puppetserver.pid
codedir = /etc/puppetlabs/code

[agent]
server = vp-cp-officeit-puppetmain01.aix.vpg.lan

[master]
storeconfigs = true
storeconfigs_backend = puppetdb

PostgreSQL

Configurer une base de données dans POTSGRESQL pour PuppetDB

apt-get install postgresql-13
su - postgres
# PAS dans le prompt 'psql'
createuser -DRSP puppetdb
createdb -E UTF8 -O postgres puppetdb
psql puppetdb -c 'revoke create on schema public from public'
psql puppetdb -c 'grant create on schema public to puppetdb'
psql puppetdb -c 'create extension pg_trgm'

Customisation pgsql

dans /etc/postgresql/13/main/postgresql.conf :

# Add settings for extensions here
listen_addresses = localhost

dans pg_hba.conf , tel que :

# Rule Name: local access as postgres user
# Description: none
# Order: 1
local	all	postgres		ident
# Rule Name: local access to database with same name
# Description: none
# Order: 2
local	all	all		ident
# Rule Name: allow localhost TCP access to postgresql user
# Description: none
# Order: 3
host	all	postgres	127.0.0.1/32	md5
# Rule Name: deny access to postgresql user
# Description: none
# Order: 4
host	all	postgres	0.0.0.0/0	reject
# Rule Name: allow access to all users
# Description: none
# Order: 100
host	all	all	0.0.0.0/0	md5
# Rule Name: allow access to ipv6 localhost
# Description: none
# Order: 101
host	all	all	::1/128	md5

NB: Selon le profil de la machine des options peuvent être finetunées avec https://pgtune.leopard.in.ua

Add/modify this settings in postgresql.conf and restart database


# DB Version: 13
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 4 GB
# CPUs num: 2
# Data Storage: ssd

max_connections = 200
shared_buffers = 1GB
effective_cache_size = 3GB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 2621kB
huge_pages = off
min_wal_size = 1GB
max_wal_size = 4GB 

Configurer puppetdb

Dans /etc/puppetlabs/puppetdb/conf.d/database.ini :

[database]
# Db connection
subname = //localhost:5432/puppetdb
username = puppetdb
password = puppetdb

# How often (in minutes) to compact the database
gc-interval = 60
classname = org.postgresql.Driver
subprotocol = postgresql
syntax_pgs = true
node-ttl = 7d
node-purge-ttl = 14d
report-ttl = 14d
log-slow-statements = 10
conn-max-age = 60
conn-keep-alive = 45
conn-lifetime = 0

Activer la configuration SSL de PuppetDB: puppetdb ssl-setup

Relancer PuppetDB: systemctl restart puppetdb

Créer un fichier /etc/puppetlabs/puppet/puppetdb.conf :

[main]
server_urls = https://vp-cp-officeit-puppetmain01.aix.vpg.lan:8081



Set the Puppet server domain name in the Puppet agent configuration:
puppet config set server vp-cp-officeit-puppetmain01.aix.vpg.lan --section agent

Relancer PuppetServer : systemctl restart puppetserver

Install puppetboard

# cf: https://github.com/voxpupuli/puppet-puppetboard
# https://forge.puppet.com/modules/puppet/puppetboard/readme



puppet module install puppet-puppetboard
puppet module install puppetlabs-apache
apt-get install python3-venv

Manifest local:

# cat /etc/puppetlabs/code/environments/production/manifests/init.pp
node /vp-cp-officeit-puppetmain01/ {

  # Configure Apache on this server
  class { 'apache':
    default_vhost => false,
  }

  # Configure Puppetboard
  class { 'puppetboard':
    secret_key     => fqdn_rand_string(32),
  }

  # Access Puppetboard through pboard.example.com
  class { 'puppetboard::apache::vhost':
    vhost_name => 'vp-cp-officeit-puppetmain01',
    port       => 80,
  }

}
#

Run this local manifest with : puppet agent -t

L’interface web devrait répondre sur l’url: http://vp-cp-officeit-puppetmain01.aix.vpg.lan





Problèmes SSL

Dans le cas de soucis d’enrollment , côté serveur:

# puppetserver ca sign --all
Successfully signed certificate request for sysrescue
# puppetserver ca clean --certname vp-dc2-pim-sql02.dc.vpg.lan

Côté client :

# rm -rf /etc/puppetlabs/puppet/ssl/*
# puppet agent -t