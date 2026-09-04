*This project has been created as part of the 42 curriculum by jel-ghna.*

# Inception

## Description

Inception is a system administration and Docker project from the 42 curriculum. The goal is to build a small infrastructure composed of multiple Docker containers and make the services work together through a dedicated Docker network.

The project consists of three main services:

* **Nginx** — acts as the only public entry point and provides HTTPS/TLS.
* **WordPress** — provides the website and runs PHP through PHP-FPM.
* **MariaDB** — provides the database used by WordPress.

The services are built from custom Dockerfiles based on Debian and are orchestrated with Docker Compose.

The resulting architecture is:

```text
                         HTTPS :443
                             |
                             v
                         +-------+
                         | Nginx |
                         +---+---+
                             |
                        FastCGI :9000
                             |
                             v
                     +---------------+
                     |   WordPress   |
                     |   PHP-FPM     |
                     +-------+-------+
                             |
                         MariaDB :3306
                             |
                             v
                     +---------------+
                     |    MariaDB    |
                     +---------------+
```

### Docker

Docker is used to isolate each service into its own container while allowing the services to communicate through a private Docker network.

Each service has its own Dockerfile:

```text
srcs/
├── docker-compose.yml
└── requirements/
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/
    │       └── default.conf
    ├── wordpress/
    │   ├── Dockerfile
    │   ├── tools/
    │   │   └── entrypoint.sh
    │   └── .env
    └── mariadb/
        ├── Dockerfile
        ├── tools/
        │   └── entrypoint.sh
        └── .env
```

Docker Compose creates the containers and connects them to the `inception` bridge network.

Only Nginx exposes a port to the host:

```text
Host :443 → Nginx :443
```

WordPress and MariaDB remain accessible only through the internal Docker network.

### Main design choices

* Debian is used as the base image for all services.
* Each service runs in its own container.
* Nginx is the only service exposed to the host.
* Nginx communicates with PHP-FPM through TCP port `9000`.
* WordPress communicates with MariaDB through the Docker network.
* HTTPS is enabled using a self-signed TLS certificate.
* PHP-FPM and MariaDB run in the foreground so Docker can monitor their main processes.
* Entrypoint scripts are used for service initialization and configuration.
* WordPress is automatically installed using WP-CLI.
* MariaDB is initialized automatically on first startup.
* Persistent WordPress and MariaDB data are stored using Docker named volumes backed by directories under `/home/jel-ghna/data/`.

## Virtual Machines vs Docker

A virtual machine virtualizes an entire operating system. Each VM normally contains its own kernel, operating system, libraries, and applications.

Docker containers instead share the host kernel and isolate applications at the process level.

| Virtual Machines              | Docker                                |
| ----------------------------- | ------------------------------------- |
| Virtualizes an entire machine | Isolates applications/processes       |
| Each VM has its own OS        | Containers share the host kernel      |
| Generally heavier             | Generally lightweight                 |
| Slower startup                | Fast startup                          |
| Stronger OS-level isolation   | Application/container-level isolation |
| More resource intensive       | More efficient for multiple services  |

For this project, Docker is more appropriate because Nginx, WordPress, and MariaDB are separate services that need to be isolated while communicating with each other.

## Secrets vs Environment Variables

Environment variables are convenient for passing configuration such as database names, usernames, passwords, and WordPress settings into containers.

For example:

```text
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=...
MYSQL_ROOT_PASSWORD=...
```

However, environment variables are not designed as a secure secret-management system. Values can potentially be exposed through container configuration or process environments.

Docker secrets are intended specifically for sensitive information. They provide a more appropriate mechanism for securely providing passwords and other credentials to services.

For this project, environment variables are used because they are sufficient for the educational scope of the 42 Inception project and are explicitly used by the service initialization scripts. The `.env` files are excluded from Git so that credentials are not committed to the repository.

## Docker Network vs Host Network

A Docker bridge network provides an isolated virtual network between containers.

In this project:

```text
nginx → wordpress:9000
wordpress → mariadb:3306
```

Service names are resolved through Docker's internal DNS.

With host networking, a container would share the host's network namespace. This removes much of the network isolation provided by Docker and can also create port conflicts with applications running on the host.

The project therefore uses a dedicated Docker bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

Only Nginx publishes a host port. WordPress and MariaDB communicate internally without exposing their ports to the host.

## Docker Volumes vs Bind Mounts

A Docker volume is managed by Docker and is designed for persistent container data.

A bind mount directly maps a host filesystem path into a container.

| Docker Volumes                         | Bind Mounts                                        |
| -------------------------------------- | -------------------------------------------------- |
| Managed by Docker                      | Managed directly through host paths                |
| Designed for persistent container data | Useful for sharing specific host files/directories |
| Portable across Docker configurations  | Tied directly to host filesystem structure         |
| Docker controls the volume lifecycle   | User controls the host directory                   |

This project uses **named Docker volumes** for WordPress and MariaDB persistence:

```text
srcs_wordpress
srcs_mariadb
```

The volumes use Docker's local volume driver with the required host storage locations:

```text
/home/jel-ghna/data/wordpress
/home/jel-ghna/data/mariadb
```

This allows the project to satisfy the requirement for persistent data under `/home/login/data` while still using named Docker volumes in the Compose configuration.

## Instructions

### Requirements

The project requires:

* Docker
* Docker Compose
* A Linux environment capable of running Docker
* A hostname configured to point to the Docker host

For this project, the hostname is:

```text
jel-ghna.42.fr
```

It must resolve to the machine running Docker.

### Configuration

Create the required data directories:

```bash
mkdir -p /home/jel-ghna/data/wordpress
mkdir -p /home/jel-ghna/data/mariadb
```

The project uses environment files for database and WordPress configuration:

```text
srcs/requirements/mariadb/.env
srcs/requirements/wordpress/.env
```

These files contain local configuration and credentials and should not be committed to Git.

### Build and start

From the project root:

```bash
make
```

or:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Check the running containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

The expected services are:

```text
nginx
wordpress
mariadb
```

### Access WordPress

Open:

```text
https://jel-ghna.42.fr
```

Because the project uses a self-signed certificate, the browser may display a certificate warning.

### Useful commands

Stop the services:

```bash
make stop
```

Start stopped services:

```bash
make start
```

Stop and remove the containers:

```bash
make down
```

Rebuild the images:

```bash
make build
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

View logs for one service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

## Persistent Data

WordPress files are stored in:

```text
/home/jel-ghna/data/wordpress
```

MariaDB data is stored in:

```text
/home/jel-ghna/data/mariadb
```

The data remains available when containers are stopped, removed, or recreated.

This allows the database and WordPress installation to survive container recreation.

## Resources

### Docker

* Docker documentation — https://docs.docker.com/
* Docker Compose documentation — https://docs.docker.com/compose/
* Docker volumes — https://docs.docker.com/engine/storage/volumes/
* Docker networking — https://docs.docker.com/engine/network/
* Dockerfile reference — https://docs.docker.com/reference/dockerfile/

### Nginx

* Nginx documentation — https://nginx.org/en/docs/
* Nginx beginner's guide — https://nginx.org/en/docs/beginners_guide.html

### WordPress

* WordPress documentation — https://wordpress.org/documentation/
* WP-CLI documentation — https://wp-cli.org/
* WP-CLI handbook — https://make.wordpress.org/cli/handbook/

### MariaDB

* MariaDB documentation — https://mariadb.com/docs/
* MariaDB Docker documentation — https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/

### TLS

* OpenSSL documentation — https://docs.openssl.org/
* Mozilla SSL Configuration Generator — https://ssl-config.mozilla.org/

### AI usage

AI was used as a learning and development aid throughout the project.

It was used to:

* Explain Docker and Docker Compose concepts.
* Explain container networking and service-to-service communication.
* Help troubleshoot Docker, MariaDB, WordPress, PHP-FPM, and Nginx configuration issues.
* Explain Docker volumes and persistent storage.
* Help design and debug MariaDB and WordPress entrypoint scripts.
* Explain and troubleshoot TLS/HTTPS configuration.
* Review Dockerfiles and Docker Compose configuration.
* Help identify configuration mistakes and understand error messages.
* Review the project structure and assist with the final documentation.

The actual project configuration, commands, testing, and implementation decisions were performed and verified by the student. AI was used primarily as a technical reference, debugging assistant, and learning tool.

