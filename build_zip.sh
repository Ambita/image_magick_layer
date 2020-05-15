#!/bin/sh

docker build . -t image_magick
CONTAINER_ID=$(docker create image_magick)
echo "Fetching from ${CONTAINER_ID}"
docker cp ${CONTAINER_ID}:/tmp/image_magick_layer.zip example/image_magick_layer/image_magick_layer.zip
echo "docker cp ${CONTAINER_ID}:/tmp/image_magick_layer.zip example/image_magick_layer/image_magick_layer.zip"
ls -lhrt example/image_magick_layer/image_magick_layer.zip
docker rm ${CONTAINER_ID}
