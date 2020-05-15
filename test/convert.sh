export GS_LIB=/opt/share/ghostscript/9.06/Resource/Init
export MAGICK_HOME=/opt
export MAGICK_CONFIGURE_PATH=/opt/etc/ImageMagick
export MAGICK_CODER_MODULE_PATH=/opt/lib64/ImageMagick-6.7.8/modules-Q16/coders
export LD_LIBRARY_PATH=/opt/lib64:/opt/lib:/lib64:/usr/lib64:/usr/lib
/opt/bin/convert -density 300 -background white -alpha remove /tmp/test.pdf -quality 100 /tmp/image.png