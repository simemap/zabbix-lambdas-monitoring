#!/bin/bash
echo "Stop the service zabbix project"
docker-compose down
echo "Remove old certificate"
mv ./etc/certbot/letsencrypt/ ./etc/certbot/letsencrypt-$(date +"%Y%m%d%H%M%S")
echo "Start certbot"
docker-compose -f docker-compose.certbot.yml up -d --force-recreate frontend
echo "Wait for 30 seconds"
sleep 30s
docker-compose -f docker-compose.certbot.yml down
sudo chown -R ubuntu ./etc/certbot/
echo "Start the service zabbix-web"
docker-compose up -d --force-recreate
sleep 10s
echo "Fix permissions"
docker exec -it -u root zabbix-web chmod 755 /etc/nginx/ssl
docker exec -it -u root zabbix-web chmod 755 /etc/nginx/options-ssl-nginx.conf
docker exec -it -u root zabbix-web chmod 755 /etc/ssl/certs/dhparam-2048.pem
#Typo error, docker user was zabbix
docker exec -it -u root zabbix-web chown -R zabbix:root /etc/nginx/ssl
docker exec -it -u root zabbix-web chown zabbix:root /etc/nginx/options-ssl-nginx.conf
docker exec -it -u root zabbix-web chown zabbix:root /etc/ssl/certs/dhparam-2048.pem

echo "Stop the project"
docker-compose down
echo "Start the project"
