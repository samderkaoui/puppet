https://shape.host/resources/puppet-server-and-agent-installation-guide-debian-11

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