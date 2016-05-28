#!/bin/bash
# <author mail="particle4dev@gmail.com" />

docker-compose up -d
docker stop NGINX
docker cp ./supervisord.conf NGINX:/etc/supervisor/conf.d/supervisord.conf
docker cp ./nginx.conf NGINX:/etc/nginx/nginx.conf
docker start NGINX
