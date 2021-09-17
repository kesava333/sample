##Install Nexus on Ubuntu 18
#!/bin/bash

_SERVER_NAME=nexus.devopschef.com
_SONATYPE_URL='https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/3/nexus-3.28.1-01-unix.tar.gz'
_SONATYPE_ROOT_DIR=/opt/nexus
_SONATYPE_USER=nexus
_NGINX_FILE=/etc/nginx/sites-enabled/nexus.conf
_SYSD_FILE=/etc/systemd/system/nexus.service

sudo adduser --shell /bin/bash --disabled-password --gecos "" $_SONATYPE_USER

sudo apt-get update
sudo apt-get install default-jdk nginx -y

sudo unlink /etc/nginx/sites-enabled/default

cd /opt/ && wget -O nexus-3.28.1-01-unix.tar.gz $_SONATYPE_URL
sudo tar -zxf nexus-3.28.1-01-unix.tar.gz

sudo  mv /opt/nexus-3.28.1-01 /opt/nexus
echo "run_as_user=$_SONATYPE_USER" | sudo tee /opt/nexus/bin/nexus.rc
sudo chown -R $_SONATYPE_USER:$_SONATYPE_USER /opt/nexus
sudo chown -R $_SONATYPE_USER:$_SONATYPE_USER /opt/sonatype-work

cat <<EOF > $_NGINX_FILE
  server {
    listen   *:80;
    server_name  $_SERVER_NAME;

    # allow large uploads of files
    client_max_body_size 1G;

    location / {
      proxy_pass http://127.0.0.1:8081/;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto "http";
    }
  }
EOF

cat <<EOF >$_SYSD_FILE
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start nexus
sudo systemctl enable nexus
sudo systemctl status nexus
