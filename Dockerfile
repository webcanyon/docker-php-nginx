FROM alpine:3.6
LABEL Maintainer="Tim de Pater <code@trafex.nl>" \
      Description="Lightweight container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux."

# Install packages
RUN apk --no-cache add --update php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype \
    php7-tokenizer php7-xdebug php7-opcache php7-sockets php7-redis php7-pdo_mysql \
    php7-dev postgresql-dev php7-pdo php7-pdo_pgsql php7-pgsql php7-session php7-mbstring \
    php7-gd php7-fileinfo php7-simplexml php7-xmlwriter php7-xml php7-zip php7-bz2 git ncurses\
    nginx supervisor curl bash bash-doc bash-completion nodejs nodejs-npm openssh vimdiff

RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
ENV LC_ALL=en_US.UTF-8

RUN npm install -G gulp

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/bashrc /root/.bashrc
COPY config/bash_profile /root/.bash_profile
COPY config/vim_profile /root/.vimrc

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
COPY src/ /var/www/html/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
