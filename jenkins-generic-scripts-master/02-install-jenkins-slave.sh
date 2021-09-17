#!/bin/bash
sudo apt-get install default-jdk make
sudo chown -R ubuntu. /opt
mkdir /opt/jenkins-workspace
cd /opt/
wget https://nodejs.org/download/release/v4.8.1/node-v4.8.1-linux-x64.tar.gz
tar xzf node-v4.8.1-linux-x64.tar.gz
mv node-v4.8.1-linux-x64 node
echo "PATH=$PATH:/opt/node/bin" | sudo tee -a /etc/environment
node --version
