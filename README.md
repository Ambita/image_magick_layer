
# ImageMagick layer builder for AWS lambda

## Introduction
Run _build_zip.sh_ to build the Docker image and copy a zip file with the layer out of the image.

## Verification
If you want to test the image locally, run
```
docker run -it image_magick
```
This will open up a bash shell in the image.

Run *docker ps* in a different shell and note the **container id**.

To test the image, copy a pdf file into it like this:
```
docker cp  <pdf filename> <container id>:/tmp/test.pdf
```
Replace *<pdf filename>* and *<container_id>* with the actual name of the test file and the **container id** you found with *docker ps*.

Run the following inside the docker image to verify correct functionality:
```
export GS_LIB=/opt/share/ghostscript/9.06/Resource/Init
export MAGICK_HOME=/opt
export MAGICK_CONFIGURE_PATH=/opt/etc/ImageMagick
export MAGICK_CODER_MODULE_PATH=/opt/lib64/ImageMagick-6.7.8/modules-Q16/coders
export LD_LIBRARY_PATH=/opt/lib64:/opt/lib:/lib64:/usr/lib64:/usr/lib
/opt/bin/convert -density 300 -background white -alpha remove /tmp/test.pdf -quality 100 /tmp/image.png
```

Copy the resulting image out of the container to view it:
```
docker cp  <container id>:/tmp/image.png .
open /tmp/image.png
```
Replace open with your application of choice if either your OS doesn't supporting open or you want to open the image in another application.