docker build -t particle4dev/cityme-media-nginx:0.5.0 ./

docker run -d -p 80:80 particle4dev/cityme-media-nginx:0.5.0

docker exec -i -t 90797dbfc806 /bin/bash