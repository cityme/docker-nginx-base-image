# cityme-media

### Build docker

`docker build -t particle4dev/cityme-nginx-api:1.0.0 ./`

### Start

`docker run -d -p 80:80 particle4dev/cityme-nginx-api:1.0.0`

### Access container docker

`docker exec -i -t NGINX /bin/bash`

### Link

`docker run -d --name API cityme-api:1.0.0`

`docker run -d -p 80:80 --name NGINX --link API:API cityme-nginx-api:1.0.0`
