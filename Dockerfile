FROM alpine:3.2
MAINTAINER Abiola Ibrahim <abiola89@gmail.com>

LABEL caddy_version="0.8.2" architecture="amd64"

RUN apk add --update openssh-client git tar php-fpm

# essential php libs
RUN apk add php-curl php-gd php-zip php-iconv php-sqlite3 php-mysql php-mysqli php-json

# allow environment variable access.
RUN echo "clear_env = no" >> /etc/php/php-fpm.conf

ARG plugins=http.git,http.cache,http.expires,http.minify,http.realip

RUN mkdir /caddysrc \
&& curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
         "https://caddyserver.com/download/linux/arm64?plugins=${plugins}&license=personal&telemetry=off" \
       | tar --no-same-owner -C /usr/bin/ -xz caddy \
&& chmod 0755 /usr/bin/caddy \
&& rm -rf /caddysrc \
&& printf "0.0.0.0\nfastcgi / 127.0.0.1:9000 php\nbrowse\nstartup php-fpm" > /etc/Caddyfile

RUN mkdir /srv \
&& printf "<?php phpinfo(); ?>" > /srv/index.php

EXPOSE 2015
EXPOSE 443
EXPOSE 80

WORKDIR /srv

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile"]
