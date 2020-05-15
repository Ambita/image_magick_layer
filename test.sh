CONTAINER_ID=$(docker create -it image_magick bash)

echo "docker cp test/test.pdf ${CONTAINER_ID}:/tmp/."
docker cp test/test.pdf ${CONTAINER_ID}:/tmp/.

echo "docker cp test/convert.sh ${CONTAINER_ID}:/tmp/."
docker cp test/convert.sh ${CONTAINER_ID}:/tmp/.

echo "docker start ${CONTAINER_ID}"
docker start ${CONTAINER_ID}

echo "docker exec ${CONTAINER_ID} sh /tmp/convert.sh"
docker exec ${CONTAINER_ID} sh /tmp/convert.sh

echo "docker cp ${CONTAINER_ID}:/tmp/image-0.png ."
docker cp ${CONTAINER_ID}:/tmp/image-0.png .

echo "docker cp ${CONTAINER_ID}:/tmp/image-1.png ."
docker cp ${CONTAINER_ID}:/tmp/image-1.png .

echo "docker stop ${CONTAINER_ID}"
docker stop ${CONTAINER_ID}

echo "docker rm ${CONTAINER_ID}"
docker rm ${CONTAINER_ID}

echo "open image*png"
open image*png
