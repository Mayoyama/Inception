# Developer Documentation

## Setting up from scratch

Prerequisites: a Linux VM with Docker and the Docker Compose plugin installed.

Two sets of configuration are required before the first build, neither of which is committed to git:

- `srcs/.env` — non-secret configuration: `DOMAIN_NAME`, `MYSQL_DATABASE`, `MYSQL_USER`, `WP_ADMIN_USER`, `WP_ADMIN_ADDRESS`, `WP_USER`, `WP_USER_ADDRESS`, `FTP_USER`.
- `secrets/` (repository root) — one plain-text file per secret, referenced by `srcs/docker-compose.yml`: `db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`, `wp_user_password.txt`, `ftp_user_secrets.txt`. Containers read these at runtime from `/run/secrets/<name>`.

Both are excluded via `.gitignore` and must be created manually on whichever machine runs the project.

## Building and launching

Everything is driven by the root `Makefile`, which wraps `docker compose --project-directory srcs -f srcs/docker-compose.yml`:

- `make build` — builds the images defined in `srcs/docker-compose.yml`, and creates the host directories the named volumes bind to if they don't already exist.
- `make compose-up` — runs `build`, then starts every container in the background.
- `make` (no target) — same as `make compose-up`, since it's the first target in the file.
- `make compose-down` — stops the containers and removes the images (`--rmi all`).
- `make clean` — runs `compose-down`, then deletes the persisted MariaDB and WordPress data from the host. Use this for a genuinely fresh start; a normal `compose-down`/`compose-up` cycle keeps your data.

## Services and ports

| Service | Built from | Published on host | Notes |
|---|---|---|---|
| nginx | `requirements/nginx` | 443 | Only entry point to WordPress; TLSv1.2/1.3, self-signed cert generated at build time. Forwards `.php` requests to `wordpress:9000`. |
| wordpress | `requirements/wordpress` | — | php-fpm on port 9000, installed and configured with wp-cli on first start. |
| mariadb | `requirements/mariadb` | — | Only reachable on the `inception` network. |
| adminer (bonus) | `requirements/bonus/adminer` | 8080 | Adminer served by PHP's built-in server. Log in with server `mariadb`. |
| portainer (bonus) | `requirements/bonus/portainer` | 9443 | Portainer binary; mounts `/var/run/docker.sock` to manage the host's Docker. |
| redis (bonus) | `requirements/bonus/redis` | — | `redis-server` on its default port 6379, capped at 256 MB with `allkeys-lru` eviction. WordPress uses it as its object cache: the `php-redis` extension is installed in the WordPress image, and on first install the entrypoint sets `WP_REDIS_HOST=redis` and installs and enables the Redis Object Cache plugin. Check with `wp redis status --path=/var/www/html --allow-root` inside the wordpress container. |
| static-site (bonus) | `requirements/bonus/static-site` | 8082 | nginx serving the plain HTML page in `html/` (copied into the image at build time) on container port 80. |
| ftp (bonus) | `requirements/bonus/ftp` | 21, 21100–21110 | vsftpd; the `FTP_USER` account is created on first start with its home set to the WordPress volume. Passive ports 21100–21110. |

All services share the `inception` bridge network and reach each other by service name.

The VM forwards host port 2121 to its port 21, so from the host machine FTP is reached at `127.0.0.1:2121` (as documented in USER_DOC.md).

## Managing containers and volumes

- `docker compose --project-directory srcs -f srcs/docker-compose.yml ps` — container status.
- `docker compose --project-directory srcs -f srcs/docker-compose.yml logs -f <service>` — follow a service's logs.
- `docker compose --project-directory srcs -f srcs/docker-compose.yml exec <service> sh` — open a shell inside a running container.
- `docker volume ls` / `docker volume inspect <name>` — inspect the named volumes. Compose prefixes them with the project name, so they appear as `srcs_mysql` and `srcs_wordpress`.

## Where data lives and how it persists

MariaDB's data and the WordPress files are each a Docker named volume (`mysql` and `wordpress` in `srcs/docker-compose.yml`), configured with a `local` driver bound to a host path rather than Docker's default volume storage — so the actual files live at `/home/speterse/data/mysql` and `/home/speterse/data/wordpress` on the host, and survive containers being stopped, removed, and rebuilt. The only thing that erases them is `make clean`.

The `wordpress` volume is shared by three containers: `wordpress` (writes the site files), `nginx` (serves them), and `ftp` (exposes them to the FTP user).

Portainer and Redis have no volume, so their state (Portainer's admin account and settings, Redis's cache) is lost whenever those containers are recreated.
