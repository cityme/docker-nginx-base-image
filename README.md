# cityme-media

### Build docker

`docker build -t particle4dev/cityme-media-nginx:0.5.0-5 ./`

### Start

`docker run -d -p 80:80 particle4dev/cityme-media-nginx:0.5.0`

### Access container docker

`docker exec -i -t NGINX /bin/bash`

### Link

`docker run -d --name MEDIA1 particle4dev/cityme-media:0.5.0-5`

`docker run -d -p 80:80 --name NGINX --link MEDIA1:MEDIA1 particle4dev/cityme-media-nginx:0.5.0-5`