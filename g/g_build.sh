#!/bin/sh
sudo apt-get update
sudo apt-get upgrade -y
 
sudo hostnamectl set-hostname arrakis-g

#Install Code Server
sudo curl -fsSL -o ~/code-server-install.sh https://code-server.dev/install.sh
sudo chmod 744 ~/code-server-install.sh
sudo ~/code-server-install.sh
# rm ~/code-server-install.sh

#Enable Code Server persistance after cloud restart
sudo systemctl enable --now code-server@$USER


#Install encryption tools and Nginx
#TODO: make the DNS a variable
sudo apt install -y nginx certbot python3-certbot-nginx

#Modify Nginx
cd /etc/nginx/sites-available
sudo rm -f code-server
sudo touch code-server
sudo chmod 777 /etc/nginx/sites-available/code-server

sudo echo "server {" > /etc/nginx/sites-available/code-server
sudo echo "    listen 80;" >> /etc/nginx/sites-available/code-server
sudo echo "    listen [::]:80;" >> /etc/nginx/sites-available/code-server
#TODO don't forget to make the DNS a variable
sudo echo "    server_name arrakis-g2.eastus.cloudapp.azure.com;" >> /etc/nginx/sites-available/code-server

sudo echo "" >> /etc/nginx/sites-available/code-server
sudo echo "    location / {" >> /etc/nginx/sites-available/code-server
sudo echo "        proxy_pass http://localhost:8080/;" >> /etc/nginx/sites-available/code-server
sudo echo "        proxy_set_header Host \$host;" >> /etc/nginx/sites-available/code-server
sudo echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/sites-available/code-server
sudo echo "        proxy_set_header Connection upgrade;" >> /etc/nginx/sites-available/code-server
sudo echo "        proxy_set_header Accept-Encoding gzip;" >> /etc/nginx/sites-available/code-server
sudo echo "    }" >> /etc/nginx/sites-available/code-server
sudo echo "}" >> /etc/nginx/sites-available/code-server

# sudo chmod 744 /etc/nginx/sites-available/code-server

#Enable the config
sudo ln -s ../sites-available/code-server /etc/nginx/sites-enabled/code-server
#NOTE: the arakis-g DNS and email need to change based on the user.
sudo certbot --non-interactive --redirect --agree-tos --nginx -d arrakis-g2.eastus.cloudapp.azure.com -m testUser@artemis-holdings.com
#Restart
sudo systemctl restart code-server@$USER

# #Reset Login Password
# #CURL Method
# cd ~/.config/code-server
# sudo rm -f config.yaml
# sudo curl -fsSL -o ~/.config/code-server/config.yaml https://raw.githubusercontent.com/Artemis-Holdings/Arrakis/main/g/config.yaml
# sudo chmod 744 ~/code-server-install.sh

# # ECHO Version
# # v1
# cd ~/.config/code-server
# sudo rm -f config.yaml
# sudo touch config.yaml
# sudo chmod 777 ~/.config/code-server/config.yaml
# sudo echo "bind-addr: 127.0.0.1:8080" > ~/.config/code-server/config.yaml
# sudo echo "auth: password" >> ~/.config/code-server/config.yaml
# sudo echo "password: ChangeThisPassword123" >> ~/.config/code-server/config.yaml
# sudo echo "cert: false" >> ~/.config/code-server/config.yaml
# sudo chmod 444 ~/.config/code-server/config.yaml
# v2
# cd ~/.config/code-server
# sudo rm -f ~/.config/code-server/config.yaml
# sudo touch ~/.config/code-server/config.yaml
# sudo chmod -R 777 ~/.config/code-server
# sudo echo "bind-addr: 127.0.0.1:8080" > ~/.config/code-server/config.yaml
# sudo echo "auth: password" >> ~/.config/code-server/config.yaml
# sudo echo "password: ChangeThisPassword123" >> ~/.config/code-server/config.yaml
# sudo echo "cert: false" >> ~/.config/code-server/config.yaml
# sudo chmod -R 444 ~/.config/code-server

#Restart
sudo systemctl --quiet restart code-server@$USER
#Force Restart
sudo curl -fsSL -o ~/code-server-restart.sh https://raw.githubusercontent.com/Artemis-Holdings/Arrakis/main/g/server_restart.sh

sudo ~/code-server-restart.sh
rm ~/code-server-restart.sh
