#!/bin/bash

set -e

DATADIR="/var/lib/mysql"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-test-db

    echo "Starting temporary MariaDB server..."

    mariadbd \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock &
    
    pid="$!"

    echo "Waiting for MariaDB to start..."

    until mariadb-admin \
        --socket=/run/mysqld/mysqld.sock \
        ping > /dev/null 2>&1
    do
        sleep 1
    done

    echo "MariaDB is ready."

    mariadb \
        --socket=/run/mysqld/mysqld.sock \
        -u root << EOF

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF

    echo "MariaDB initialization complete."

    echo "Stopping temporary MariaDB server..."

    mariadb-admin \
        --socket=/run/mysqld/mysqld.sock \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" shutdown

    wait "$pid"
fi

echo "Starting MariaDB..."

exec mariadbd --user=mysql --console

