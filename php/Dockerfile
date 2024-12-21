FROM php:8.4-fpm

# Installer des dépendances nécessaires et extensions PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    zip \
    libicu-dev \
    libpq-dev \
    iproute2 \
    gosu \
    && echo "dockeruser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && docker-php-ext-install pdo_pgsql zip intl opcache \
    && apt-get clean

# Installer et activer Xdebug via PECL
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug


RUN mkdir -p /usr/local/etc/php/conf.d && \
    chmod -R 0777 /usr/local/etc/php/conf.d

#
## Désactiver short_open_tag dans php.ini
#RUN { \
#    echo 'short_open_tag = Off'; \
#    echo 'opcache.enable=1'; \
#    echo 'opcache.memory_consumption=128'; \
#    echo 'opcache.interned_strings_buffer=8'; \
#    echo 'opcache.max_accelerated_files=10000'; \
#    echo 'opcache.revalidate_freq=2'; \
#    echo 'opcache.fast_shutdown=1'; \
#  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Ajouter l'utilisateur non-root user
RUN groupadd dockeruser && \
    # Crée un groupe
    groupadd docker_group && \
    # Crée un utilisateur dockeruser avec le shell /bin/sh, associé au groupe docker_group
    useradd -m -s /bin/bash -g docker_group dockeruser && \
    # Crée un utilisateur docker et l'ajouter au groupe sudo
    useradd -m -s /bin/bash -G sudo docker && \
    ls -ld /home/dockeruser && \
    # Crée le répertoire /app
    mkdir -p /app

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Télécharge et installe le binaire Symfony
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Copie de la configuration de PHP
COPY php.ini ${PHP_INI_DIR}/php.ini
COPY php-ini-overrides.php ${PHP_INI_DIR}/php-ini-overrides.php

# Copie les configurations des extensions
COPY opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Configuration du répertoire de travail
WORKDIR /app

# Copie du script d'entrée et définition de l'entrée par défaut
COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# Définition du prompt (PS1) pour le shell interactif :
# - `\[\e[38;5;81m\]` : Séquence d'échappement ANSI pour définir la couleur du texte à un bleu clair spécifique du modèle de couleur 256.
# - `🐳 DOCKER:` : Affiche l'emoji de la baleine suivi du texte "DOCKER" en bleu clair.
# - `\[\e[0m\]` : Séquence d'échappement ANSI pour réinitialiser les couleurs à leurs valeurs par défaut.
# - `\w` : Variable du shell qui affiche le chemin du répertoire de travail courant.
# - `\$` : Affiche le symbole `$`
# La commande echo ajoute cette définition de prompt au fichier `.bashrc` de l'utilisateur root du conteneur,
# de sorte que chaque fois qu'un shell interactif est démarré, ce prompt personnalisé est utilisé.
RUN echo "export PS1='[\[\e[38;5;245m\]🐳 DOCKER:\[\e[38;5;64m\]\w\[\e[38;5;245m\]\[\e[0m\]]\$ '" >> /root/.bashrc

ENTRYPOINT ["/entrypoint"]
