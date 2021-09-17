#!/bin/bash

#Setup Nginx
sudo apt-get update
sudo apt install -y nginx 
sudo unlink /etc/nginx/sites-enabled/default
vm_ip=`curl -s  -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip`
cat << EOF > /etc/nginx/sites-enabled/default
server {
    listen 80;
    server_name $vm_ip;
     
    location / {
      proxy_set_header        Host \$host:\$server_port;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;
 
      # Fix the "It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://127.0.0.1:8081;
      proxy_read_timeout  90;
 
      proxy_redirect      http://127.0.0.1:8081 http://$vm_ip;
  
      # Required for new HTTP-based CLI
      proxy_http_version 1.1;
      proxy_request_buffering off;
    }
  }
EOF
sudo service nginx restart

#Install Docker Engine
sudo apt-get install -y  \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

#Deploy Jenkins.
sudo mkdir -p /opt/jenkins-root/jenkins-vol
cd /opt/jenkins-root/
cat << EOF > docker-compose.yaml
version: '3.7'
services:
  jenkins:
    image: jenkins/jenkins:lts
    privileged: true
    user: root
    ports:
      - 8081:8080
      - 50000:50000
    container_name: jenkins
    volumes:
      - jenkins-vol:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/local/bin/docker:/usr/local/bin/docker
volumes:
  jenkins-vol:
EOF
docker-compose up -d
sleep 30
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
