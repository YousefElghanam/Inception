#!/bin/bash

set -e

cat > /etc/wordpress/config-jel-ghna.42.fr.php << EOF
<?php

define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', '${DB_HOST}');

define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
define('WP_CONTENT_URL', '/wp-content');

\$table_prefix = 'wp_';
EOF

chown -R www-data:www-data /usr/share/wordpress/wp-content

until mariadb-admin ping \
    -h"${DB_HOST}" \
    -u"${DB_USER}" \
    -p"${DB_PASSWORD}" \
    --silent
do
    echo "Waiting for MariaDB..."
    sleep 2
done

if ! wp core is-installed --path=/usr/share/wordpress --allow-root; then
    wp core install \
        --path=/usr/share/wordpress \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
fi

if ! wp user get "${WP_USER2}" --path=/usr/share/wordpress --allow-root >/dev/null 2>&1; then
    wp user create \
        "${WP_USER2}" \
        "${WP_USER2_EMAIL}" \
        --role="${WP_USER2_ROLE}" \
        --path=/usr/share/wordpress \
        --allow-root
fi

exec php-fpm8.4 -F
