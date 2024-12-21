#!/bin/sh

cat "${PHP_INI_DIR}"/php.ini >"${PHP_INI_DIR}"/conf.d/99-overrides.ini

# Si VERBOSE n'est pas défini, alors debug_message est true, qui est une commande shell valide qui ne fait rien et ne produit aucune sortie.
debug_message='true'
if [ -n "${VERBOSE}" ]; then
  debug_message='echo'
fi

if [ "$(id -u)" -eq 0 ]; then
  $debug_message "Mise à jour de /etc/passwd et /etc/group avec les UID et GID de l'utilisateur"
  sed -i -r "s/$username:x:\d+:\d+:/$username:x:$uid:$gid:/g" /etc/passwd
  sed -i -r "s/$group:x:\d+:/$group:x:$gid:/g" /etc/group

  $debug_message "Mise à jour de la configuration php-fpm pour utiliser l'utilisateur et le groupe spécifié"
  sed -i "s/user = www-data/user = $username/g" /usr/local/etc/php-fpm.d/www.conf
  sed -i "s/group = www-data/group = $group/g" /usr/local/etc/php-fpm.d/www.conf

  $debug_message "Changement de propriétaire de /home/cnamuser pour l'utilisateur et le groupe spécifié"
  mkdir -p /home/cnamuser
  chown $username:$group -R /home/cnamuser
else
  echo "Erreur : Ces modifications nécessitent les droits root."
  exit 1
fi

if [ -z "${DEBUG_MODE}" ] || [ "${DEBUG_MODE}" = 'pcov' ]; then
  $debug_message "Xdebug est désactivé"
  sed -i 's/zend_extension/;zend_extension/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
else
  $debug_message "Xdebug est activé"
fi

if [ -z "${XDEBUG_REMOTE_HOST}" ] && [ "${DEBUG_MODE}" = "xdebug" ]; then
  XDEBUG_REMOTE_HOST=$(ip route | awk '/default/ { print $3 }')
  export XDEBUG_REMOTE_HOST

  # Ajout des overrides PHP INI
  $debug_message "Ajout des overrides de PHP INI"
  php "${PHP_INI_DIR}/php-ini-overrides.php" >> "${PHP_INI_DIR}/conf.d/99-overrides.ini"
fi

# Vérifie si des arguments ont été passés au script. Si aucun argument n'a été passé ($# est égal à 0), alors le script démarre php-fpm
if [ $# -eq 0 ]; then
  $debug_message "Démarrage de php-fpm"
  php-fpm
fi

$debug_message "Configuration de l'utilisateur dockeruser"
DOCKER_USER='dockeruser'

# Définition du prompt (PS1) pour le shell interactif :
# - `\[\e[38;5;81m\]` : Séquence d'échappement ANSI pour définir la couleur du texte à un bleu clair spécifique du modèle de couleur 256.
# - `🐳 DOCKER:` : Affiche l'emoji de la baleine suivi du texte "DOCKER" en bleu clair.
# - `\[\e[0m\]` : Séquence d'échappement ANSI pour réinitialiser les couleurs à leurs valeurs par défaut.
# - `\w` : Variable du shell qui affiche le chemin du répertoire de travail courant.
# - `\$` : Affiche le symbole `$`
# La commande echo ajoute cette définition de prompt au fichier `.bashrc` de l'utilisateur $DOCKER_USER du conteneur,
# de sorte que chaque fois qu'un shell interactif est démarré, ce prompt personnalisé est utilisé.
echo "export PS1='[\[\e[38;5;245m\]🐳 DOCKER:\[\e[38;5;64m\]\w\[\e[38;5;245m\]\[\e[0m\]]\$ '" >> /home/$DOCKER_USER/.bashrc

# Cela permet de récupérer les droits actuels de l'utilisateur et du groupe hôte de /app qui est le volume partagé avec l'hôte.
$debug_message "Récupération des UID et GID de /app"
uid=$(stat -c '%u' /app)
gid=$(stat -c '%g' /app)

if [ "$uid" = 0 ] && [ "$gid" = 0 ]; then
  $debug_message "Aucun droit spécifique pour l'utiliser dockeruser"
  if [ $# -eq 0 ]; then
    $debug_message "Démarrage de php-fpm en tant que root car UID et GID sont 0"
    php-fpm --allow-to-run-as-root
  else
    $debug_message "Exécution de la commande personnalisée: $*"
    exec "$@"
  fi
fi

$debug_message "Exécution de la commande en tant que $DOCKER_USER ($uid:$gid): $*"
exec gosu "$DOCKER_USER" "$@"
