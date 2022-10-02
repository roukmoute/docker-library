FROM composer:2

RUN set -eux ; \
  apk add --no-cache bash

RUN set -eux ; \
  # install Symfony CLI https://symfony.com/download
  curl \
    --tlsv1 \
    --silent \
    --fail \
    --location \
    --retry 3 \
    --output /tmp/symfony.setup.sh \
    --url https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh \
  ; \
  chmod +x /tmp/symfony.setup.sh ; \
  bash /tmp/symfony.setup.sh ; \
  apk add symfony-cli ; \
  rm /tmp/symfony.setup.sh ; \
  symfony -V

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["symfony"]
