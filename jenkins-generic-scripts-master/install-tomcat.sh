#Install Tomcat

apt install default-jdk -y
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.tar.gz
mkdir -p /opt/tomcat
mv apache-tomcat-9.0.8.tar.gz /opt/tomcat/
cd /opt/tomcat
tar -xvzf /opt/tomcat/apache-tomcat-9.0.8.tar.gz

###Create User and Groups for Tomcat##
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
chgrp -R tomcat /opt/tomcat
cd /opt/tomcat/apache-tomcat-9.0.8
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/
update-java-alternatives -l

##Create a service for Tomcat
cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
After=syslog.target network.target
[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/apache-tomcat-9.0.8/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat/apache-tomcat-9.0.8
Environment=CATALINA_BASE=/opt/tomcat/apache-tomcat-9.0.8
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
WorkingDirectory=/opt/tomcat/apache-tomcat-9.0.8
ExecStart=/opt/tomcat/apache-tomcat-9.0.8/bin/startup.sh
ExecStop=/opt/tomcat/apache-tomcat-9.0.8/bin/shutdown.sh
User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
EOF

##Start Tomcat
systemctl start tomcat
systemctl status tomcat

##Access Tomcat
#http://Host_IP:8080
