#!/bin/bash

set -e

echo "===== 1: ENTRYPOINT STARTED ====="

DATADIR="/var/lib/mysql"

echo "===== 2: DATADIR=$DATADIR ====="
echo "===== 3: CHECKING MYSQL DIRECTORY ====="

if [ ! -d "$DATADIR/mysql" ]; then

    echo "===== 4: MYSQL DIRECTORY DOES NOT EXIST ====="

    mkdir -p /run/mysqld
    chown mysql:mysql /run/mysqld

    echo "===== 5: RUNNING mariadb-install-db ====="

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-test-db

    echo "===== 6: mariadb-install-db FINISHED ====="

    echo "Starting temporary MariaDB server..."

    mariadbd \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock &

    pid="$!"

    echo "===== 7: TEMP SERVER STARTED, PID=$pid ====="

    echo "Waiting for MariaDB to start..."

    until mariadb-admin \
        --socket=/run/mysqld/mysqld.sock \
        ping > /dev/null 2>&1
    do
        sleep 1
    done

    echo "===== 8: MARIA DB IS READY ====="

    mariadb \
        --socket=/run/mysqld/mysqld.sock \
        -u root << EOF

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF

    echo "===== 9: SQL FINISHED ====="

    mariadb-admin \
        --socket=/run/mysqld/mysqld.sock \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" shutdown

    wait "$pid"

    echo "===== 10: TEMP SERVER STOPPED ====="
fi

echo "===== 11: STARTING FINAL MARIADB ====="

exec mariadbd --user=mysql --console