<?php

if (in_array('xdebug', get_loaded_extensions())) {
    printf('%s# Xdebug%s', PHP_EOL, PHP_EOL);
    printf('xdebug.client_host=%s%s', getenv('XDEBUG_REMOTE_HOST'), PHP_EOL);
    printf('xdebug.mode=debug%s', PHP_EOL);
}
