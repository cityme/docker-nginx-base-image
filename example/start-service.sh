#!/bin/bash
# <author mail="particle4dev@gmail.com" />

docker-compose up -d
docker stop CONSUL_NGINX
# docker cp ./supervisord.conf CONSUL_NGINX:/etc/supervisor/conf.d/supervisord.conf
docker cp ./nginx.conf CONSUL_NGINX:/etc/nginx/nginx.conf
docker start CONSUL_NGINX
