##Jenkins Installation on Ubuntu 18
hostname
##Set-Hostname
hostnamectl set-hostname jenkins-master
##Verify java 
java --version
#Install Java
sudo add-apt-repository ppa:webupd8team/java
apt update
apt install openjdk-8-jdk

##Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
sudo apt-get update
sudo apt-get install jenkins

##Verify the Jenkins Status
service jenkins status
netstat -tulpn

#Unlock Jenkins
cat /var/lib/jenkins/secrets/initialAdminPassword
