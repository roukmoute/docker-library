#!/bin/sh

cat "${PHP_INI_DIR}"/php.ini >"${PHP_INI_DIR}"/conf.d/99-overrides.ini

if [ -z "$DOCKER_USER" ]; then
  DOCKER_USER='webuser'
fi

uid=$(id -ur "${DOCKER_USER}")
gid=$(id -gr "${DOCKER_USER}")

if [ "$uid" = 0 ] && [ "$gid" = 0 ]; then
  if [ $# -eq 0 ]; then
    php-fpm --allow-to-run-as-root
  else
    echo "using $*"
    exec "$@"
  fi
fi

username=$(id -un "${DOCKER_USER}")
group=$(id -gn "${DOCKER_USER}")

sed -i -r "s/$username:x:\d+:\d+:/$username:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/$group:x:\d+:/$group:x:$gid:/g" /etc/group

sed -i "s/user = www-data/user = $username/g" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/group = www-data/group = $group/g" /usr/local/etc/php-fpm.d/www.conf

user=$(grep ":x:$uid:" /etc/passwd | cut -d: -f1)
if [ $# -eq 0 ]; then
  php-fpm
else
  echo gosu "$user" "$@"
  exec gosu "$user" "$@"
fi
