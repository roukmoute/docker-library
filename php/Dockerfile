# Définition des variables d'environnement pour Composer et PHP
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG COMPOSER_VERSION=2
ARG PHP_VERSION=8.3-rc

# Utilisation de l'image Composer pour installer les dépendances
FROM composer:${COMPOSER_VERSION} as composer
# Utilisation de l'image PHP-FPM Alpine
FROM php:${PHP_VERSION}-fpm-alpine

# Définition de la zone horaire de Paris
ENV TZ="Europe/Paris"

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    autoconf \
    bind-tools \
    ca-certificates \
    freetype-dev \
    git \
    gnupg \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libmemcached-dev \
    libpng \
    libpng-dev \
    libssh2 \
    libssh2-dev \
    libxml2-dev \
    libzip-dev \
    make \
    postgresql-dev \
    sudo \
    unzip \
    zip \
    zlib-dev \
    # Installation de dépendances PHP supplémentaires pour l'internationalisation (intl)
    tzdata \
    icu-dev \
    icu-data-full \
    # Configuration de la zone horaire et des extensions PHP
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install bcmath calendar gd intl opcache pcntl pdo pdo_pgsql soap zip \
    # Installation de pcov, xdebug, memcached, ast et ssh2
    && pecl install pcov memcached ast ssh2-1.3.1 \
    && docker-php-ext-enable gd ssh2 pcov memcached ast \
    #    && pecl install xdebug && docker-php-ext-enable xdebug \
    && docker-php-source delete \
    # Installation de gosu pour permettre un changement d'utilisateur sûr
    && apk add gosu --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && addgroup webuser \
    && adduser -D -s /bin/sh -G webuser webuser \
    && adduser -D -s /bin/sh docker sudo \
    && mkdir -p /app

# Ajout de Xdebug
RUN apk add --update linux-headers
RUN apk add -U php8-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && docker-php-ext-enable xdebug

# Ajout de la configuration de sudoers
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN rm -rf /var/cache/apk/*

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copie de la configuration de PHP
COPY php.ini ${PHP_INI_DIR}/php.ini

# Configuration du répertoire de travail
WORKDIR /app

# Copie du script d'entrée et définition de l'entrée par défaut
COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

ENTRYPOINT ["/entrypoint"]

