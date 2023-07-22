# Dockerfile for Red Hat Universal Base Images
#
# Maintainer: Erivando Sena <erivandosenas@gmail.com>
#
# Description: Este Dockerfile cria uma imagem para Red Hat Universal Base Images, para construir containers baseados no RHEL.
#
# Build instructions:
#   docker build -t erivando/ubis-redhat:latest .
#
# Usage:
#
#   docker run --rm -it --nameme ubis-redhat -p 8880:80 erivando/ubis-redhat:latest
#   docker logs -f --tail --until=2s ubis-redhat
#   docker exec -it ubis-redhat bash
#
# Dependencies: ubi8/ubi:8.1
#
# Environment variables:
#
# N/A
#
# Notes:
#
# - Este Dockerfile assume que o código do aplicativo está localizado no diretório atual
# - O aplicativo pode ser acessado em um navegador da Web em http://localhost:8880/
#
# Version: 1.0

FROM registry.access.redhat.com/ubi8/ubi@sha256:ba803ecfde6ad36bb739ab2858c0eea2e4c0257a42905ffa25018368079ec2f9

RUN yum -y update && yum clean all

RUN yum --disableplugin=subscription-manager -y module enable php:8.* \
  && yum --disableplugin=subscription-manager -y install httpd php \
  && yum --disableplugin=subscription-manager clean all

RUN mv /usr/share/testpage/* /var/www/html \
    && rm -R /usr/share/testpage

RUN chown -Rf apache:apache /var/www/html \
 && echo "<?php phpinfo(); phpinfo(INFO_MODULES); ?>" > /var/www/html/phpinfo.php \
 && sed -i 's/user = apache/;user = apache/' etc/php-fpm.d/www.conf \
 && sed -i 's/group = apache/;group = apache/' etc/php-fpm.d/www.conf

RUN sed -i 's/#ServerName www.example.com:80/ServerName localhost/' /etc/httpd/conf/httpd.conf \
 && sed -i 's/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf \
 && sed -i 's/ErrorLog "logs\/error_log"/ErrorLog "\/dev\/stderr"/' /etc/httpd/conf/httpd.conf \
 && sed -i 's/listen.acl_users = apache,nginx/listen.acl_users =/' /etc/php-fpm.d/www.conf \
 && mkdir /run/php-fpm \
 && chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm \
 && chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm 

WORKDIR /var/www/html

USER 1000

EXPOSE 80

LABEL \
  org.opencontainers.image.vendor="Red Hat" \
  org.opencontainers.image.description="PHP and Apache HTTP Server on Red Hat Universal Base Image 8.1" \
  org.opencontainers.image.maintainer="Erivando Sena<erivandosena@gmail.com>"

CMD php-fpm & httpd -D FOREGROUND
