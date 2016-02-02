#!/bin/bash
# <author mail="particle4dev@gmail.com" />

docker build -t particle4dev/cityme-nginx-image:$1 ./
# docker tag particle4dev/cityme-nginx-image@$1 localhost:5000/particle4dev/cityme-nginx-image@$1
# docker push localhost:5000/particle4dev/cityme-nginx-image@$1
