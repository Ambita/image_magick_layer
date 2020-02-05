FROM amazonlinux:2

RUN yum -y update && yum -y install ghostscript ImageMagick zip

# Prepare opt for ouir libraries
RUN mkdir /opt/{bin,etc,lib64,share}

# Move ghostscript
RUN mv /usr/bin/ghostscript /opt/bin/.
RUN mv /usr/bin/gs /opt/bin/.
RUN mv /usr/lib64/ghostscript /opt/lib64/
RUN mv /usr/lib64/libgs.* /opt/lib64/.
RUN mv /usr/lib64/libpng15.* /opt/lib64/.
RUN mv /usr/share/ghostscript /opt/share/.

# Move ImageMagick
RUN mv /etc/ImageMagick/ /opt/etc/.
RUN mv /usr/bin/convert /opt/bin/convert
RUN mv /usr/lib64/ImageMagick-6.7.8 /opt/lib64/.
RUN mv /usr/lib64/libMagick* /opt/lib64/.
RUN mv /usr/share/ImageMagick-6.7.8 /opt/share/.

# Fix ImageMagick paths
RUN sed -i 's|&quot;gs&quot|\&quot;/opt/bin/gs\&quot|' /opt/etc/ImageMagick/delegates.xml
RUN sed 's|/usr|/opt|g' -i /opt/etc/ImageMagick/type-ghostscript.xml

RUN cd /opt && zip -rq /tmp/image_magick_layer.zip .

