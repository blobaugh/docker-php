FROM php:8.1.3-apache

LABEL maintainer="ben@lobaugh.net"

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
ARG DEBIAN_FRONTEND=noninteractive

# Download script to install PHP extensions and dependencies
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

# Install and activate the libraries we need
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg-dev \
        libmagickwand-dev \
        libpng-dev \
        libzip-dev \
        vim \
        libxml2-dev \
        rsync \
        libcap2-bin \
        less \
        wget; \
    install-php-extensions \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        intl \
        ldap \
        memcached \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        redis \
        soap \
        xsl \
        zip ; \
    pecl install xdebug; \
    docker-php-ext-enable xdebug; \
#    pecl install imagick; \
#    docker-php-ext-enable imagick; \
    a2enmod rewrite headers expires;

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install NVM
# Things gonna get wonky in here. The way nvm installs inside Docker can be a bit
# complicated. This install script was taken from researching how others have done
# it. 

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.16

WORKDIR $NVM_DIR

RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

WORKDIR /var/www/html

# End NVM install

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp;

# Developer assistance
RUN echo "alias wp='wp --allow-root' >> ~/.bashrc"

# Cleanup
RUN rm -rf /usr/src/*

# Copy in the webapp - useful if we want a prod container
#COPY src/ /var/www/html/

#Change access righs to conf, logs, bin from root to www-data
RUN chown -hR www-data:www-data /var/log/apache2/
RUN chown -hR www-data:www-data /var/run/apache2/

#setcap to bind to privileged ports as non-root
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2
RUN getcap /usr/sbin/apache2

# Update the webapp permissions so the site can write files
RUN chown -R www-data:www-data /var/www/html
RUN usermod -a -G root www-data
USER www-data
