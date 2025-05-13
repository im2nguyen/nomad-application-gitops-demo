#!/bin/bash

# Install redis
sudo apt-get install -y lsb-release curl gpg

curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

sudo apt-get update

sudo apt-get install -y redis

# Redis (port 6379)
sudo systemctl enable redis-server
sudo systemctl start redis-server

# nginx config change for backend host (backend:8080 is for docker configs)
# sudo sed -i "s/backend:8080/localhost:8080/g" /etc/nginx/conf.d/default.conf

# nginx installation overwrites default file; move terramino file until after installation
cp /usr/share/nginx/html/index.html /usr/share/nginx/html/terramino.html

# Frontend set up (nginx runs on port 8081)
sudo apt update
sudo apt install -y nginx

# replace default index with terramino
rm /usr/share/nginx/html/index.html
mv /usr/share/nginx/html/terramino.html /usr/share/nginx/html/index.html

# Backend set up
# Install go dependencies
sudo add-apt-repository ppa:longsleep/golang-backports

sudo apt update && sudo apt install -y golang-go

cd /app

go mod download

# Build server
go build -o terramino

# Build CLI client
go build -o terramino-cli cmd/cli/main.go

# Nginx
sudo systemctl start nginx

# Terramino
cat >> /app/terramino.service << EOF
[Unit]
Description=Terramino service.

[Service]
Type=simple
Environment="REDIS_HOST=localhost"
Environment="REDIS_PORT=6379"
ExecStart=/app/terramino
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable /app/terramino.service
sudo systemctl start terramino.service