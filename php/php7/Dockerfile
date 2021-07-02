FROM composer:1.10.17

RUN set -eux; \
  docker-php-ext-install -j "$(nproc)" \
    bcmath \
  ; \
