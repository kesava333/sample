#!/bin/bash
sudo apt-get install default-jdk
mkdir /opt/src/
sudo chown -R ubuntu. /opt/src/
cd /opt/src/
wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar zxf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 maven
echo "PATH=$PATH:/opt/src/maven/bin/" | sudo tee -a /etc/environment
source /etc/environment
