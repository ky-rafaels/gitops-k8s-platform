#!/bin/bash
#  Script that sets up a base set of tools for Ubuntu

#  set -x

mkdir -p /data/install
cd /data/install
#
# Add Network Stuff
#
apt-get install  -y nmap						
apt-get install  -y net-tools			
apt-get install  -y pkgconf				

#
# Setup K8s
#
snap install --classic kubectl    					

#
# K8s Utilities
#	
curl -O https://raw.githubusercontent.com/blendle/kns/master/bin/kns
install -o root -g root -m 0755 /data/install/kns /usr/local/bin/kns			

curl -O https://raw.githubusercontent.com/blendle/kns/master/bin/ktx
install -o root -g root -m 0755 /data/install/ktx /usr/local/bin/ktx     						

apt-get install  -y kubectx

#
# Helm
#	
curl -O https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x /data/install/get-helm-3
cp /data/install/get-helm-3 /usr/local/bin/helm

# Setup K9s

curl -O https://github.com/derailed/k9s/releases/download/v0.50.9/k9s_linux_amd64.deb
apt-get install  -y /data/install/k9s_linux_amd64.deb

#
# Setup Kind
#
curl -O https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
install -o root -g root -m 0755 /data/install/kind-linux-amd64 /usr/local/bin/kind										

#
# Setup fzf
#
curl -O https://github.com/junegunn/fzf/releases/download/v0.65.2/fzf-0.65.2-linux_amd64.tar.gz
tar -xf /data/install/fzf-0.65.2-linux_amd64.tar.gz -C /data/install
install -o root -g root -m 0755 /data/install/fzf /usr/local/bin/fzf

#
# Setup Flux
#
curl -O https://fluxcd.io/install.sh
chmod +x /data/install/flux-install.sh 
/data/install/flux-install.sh

#
# Setup Docker FORCE VERSION 28.0.4
#  
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:  # Latest for current OS
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null


# Add jammy Repo as well
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 	
add-apt-repository -y \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    jammy \
    stable"

apt-get update

# For latest version of docker, now 29.x.x
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

getent group docker  					# group docker should already out there...
usermod -aG docker ubuntu && newgrp docker
usermod -aG docker nutanix && newgrp docker

# Start'em up!
systemctl enable docker.service
systemctl start docker.service

chown -R nutanix:nutanix /home/nutanix

    
echo "Done!"
    
#
# Restart
#
shutdown now -r

