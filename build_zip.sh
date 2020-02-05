#!/bin/sh

docker build . -t image_magick
CONTAINER_ID=$(docker create image_magick)
echo "Fetching from ${CONTAINER_ID}"
docker cp ${CONTAINER_ID}:/tmp/image_magick_layer.zip image_magick_layer.zip
docker rm ${CONTAINER_ID}
