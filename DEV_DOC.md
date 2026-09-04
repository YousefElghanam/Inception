# User Documentation

## Overview

This project provides a small web infrastructure built with Docker.

The stack consists of three services:

* **Nginx** — handles HTTPS connections and serves as the public entry point.
* **WordPress** — provides the website and administration interface.
* **MariaDB** — stores the WordPress database.

The services communicate through a private Docker network.

Only Nginx is accessible from outside the Docker network.

## Starting the Project

From the project root, run:

```bash
make
```

Alternatively, using Docker Compose directly:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

To check that everything started correctly:

```bash
docker compose -f srcs/docker-compose.yml ps
```

You should see three running services:

```text
nginx
wordpress
mariadb
```

## Stopping the Project

To stop the running containers:

```bash
make stop
```

To stop and remove the containers:

```bash
make down
```

Removing the containers does **not** remove the persistent WordPress and MariaDB data.

## Accessing the Website

The website is available at:

```text
https://jel-ghna.42.fr
```

Because the project uses a self-signed certificate, the browser may display a security warning. This is expected for this development project.

## Accessing the Administration Panel

The WordPress administration panel is available at:

```text
https://jel-ghna.42.fr/wp-admin
```

The administrator account is created automatically during the first WordPress initialization.

The administrator username is configured in:

```text
srcs/requirements/wordpress/.env
```

Look for:

```text
WP_ADMIN_USER
WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL
```

The administrator username used by this project is:

```text
josef
```

A second WordPress user is also created automatically. Its configuration is controlled by:

```text
WP_USER2
WP_USER2_EMAIL
WP_USER2_ROLE
```

## Credentials

Database and WordPress credentials are stored in environment files.

MariaDB credentials:

```text
srcs/requirements/mariadb/.env
```

WordPress credentials:

```text
srcs/requirements/wordpress/.env
```

These files contain sensitive information and **must not be committed to Git**.

The `.env` files are excluded using `.gitignore`.

If credentials need to be changed, update the appropriate environment file and recreate the relevant containers.

For example:

```bash
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml up -d
```

> Note: changing database credentials after MariaDB has already been initialized may require manually updating the corresponding MariaDB user because the existing database is stored persistently.

## Checking the Services

### Check container status

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three containers should show a status of `Up`.

### Check logs

To view all logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

To view a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

Follow logs in real time with:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Test the website

From the Docker host:

```bash
curl -k -I https://jel-ghna.42.fr
```

A working installation should return:

```text
HTTP/1.1 200 OK
```

### Check MariaDB

You can check whether MariaDB is responding from the WordPress container:

```bash
docker exec wordpress mariadb-admin ping -h mariadb -u wp_user -p
```

A successful result contains:

```text
mysqld is alive
```

## Persistent Data

The project stores persistent data outside the containers.

WordPress data:

```text
/home/jel-ghna/data/wordpress
```

MariaDB data:

```text
/home/jel-ghna/data/mariadb
```

This means that removing and recreating containers does not normally remove the website or database.

For this reason, **do not delete these directories unless you intentionally want to erase the project's persistent data.**

