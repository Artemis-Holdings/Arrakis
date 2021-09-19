#!/bin/sh
sudo apt update
sudo apt upgrade -y
 
sudo hostnamectl set-hostname arrakis-g

#Install Code Server
curl -fsSL https://code-server.dev/install.sh | sh
#Enable Code Server persistance after restart
sudo systemctl enable --now code-server@$USER


#Establish Encryption
#TODO: make the DNS a variable
sudo apt install -y nginx certbot python3-certbot-nginx

#Certificate modification
sudo touch /etc/nginx/sites-available/code-server
sudo chmod 777 /etc/nginx/sites-available/code-server

sudo echo " server {" >> /etc/nginx/sites-available/code-server
sudo echo "listen 80;" >> /etc/nginx/sites-available/code-server
sudo echo "listen [::]:80;" >> /etc/nginx/sites-available/code-server
#TODO don't forget to make the DNS a variable
sudo echo "server_name arrakis-g.eastus.cloudapp.azure.com;" >> /etc/nginx/sites-available/code-server
sudo echo "location / {" >> /etc/nginx/sites-available/code-server
sudo echo "proxy_pass http://localhost:8080/;" >> /etc/nginx/sites-available/code-server
sudo echo "proxy_set_header Host $host;" >> /etc/nginx/sites-available/code-server
sudo echo "proxy_set_header Upgrade $http_upgrade;" >> /etc/nginx/sites-available/code-server
sudo echo "proxy_set_header Connection upgrade;" >> /etc/nginx/sites-available/code-server
sudo echo "proxy_set_header Accept-Encoding gzip;" >> /etc/nginx/sites-available/code-server
sudo echo "}" >> /etc/nginx/sites-available/code-server
sudo echo "}" >> /etc/nginx/sites-available/code-server

sudo chmod 0444 /etc/nginx/sites-available/code-server

#Enable the config
sudo ln -s ../sites-available/code-server /etc/nginx/sites-enabled/code-server
#NOTE: the arakis-g DNS and email need to change based on the user.
sudo certbot --non-interactive --redirect --agree-tos --nginx -d arrakis-g.eastus.cloudapp.azure.com -m testUser@artemis-holdings.com


#Reset Login Password
sudo echo "bind-addr: 127.0.0.1:8080" > ~/.config/code-server/config.yaml
sudo echo "auth: password" >> ~/.config/code-server/config.yaml
sudo echo "password: SuperCharming123!@#" >> ~/.config/code-server/config.yaml
sudo echo "cert: false" >> ~/.config/code-server/config.yaml

#Restart
sudo systemctl restart code-server@$USER
