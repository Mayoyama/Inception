# Developer Documentation

## Setting up from scratch

Prerequisites: a Linux VM with Docker and the Docker Compose plugin installed.

Two sets of configuration are required before the first build, neither of which is committed to git:

- `srcs/.env` — non-secret configuration: `DOMAIN_NAME`, `MYSQL_DATABASE`, `MYSQL_USER`, `WP_ADMIN_USER`, `WP_ADMIN_ADDRESS`, `WP_USER`, `WP_USER_ADDRESS`.
- `secrets/` (repository root) — one plain-text file per secret, referenced by `srcs/docker-compose.yml`: `db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`, `wp_user_password.txt`. Containers read these at runtime from `/run/secrets/<name>`.

Both are excluded via `.gitignore` and must be created manually on whichever machine runs the project.

## Building and launching

Everything is driven by the root `Makefile`, which wraps `docker compose --project-directory srcs -f srcs/docker-compose.yml`:

- `make build` — builds the images defined in `srcs/docker-compose.yml`, and creates the host directories the named volumes bind to if they don't already exist.
- `make compose-up` — runs `build`, then starts every container in the background.
- `make` (no target) — same as `make compose-up`, since it's the first target in the file.
- `make compose-down` — stops the containers and removes the images (`--rmi all`).
- `make clean` — runs `compose-down`, then deletes the persisted MariaDB and WordPress data from the host. Use this for a genuinely fresh start; a normal `compose-down`/`compose-up` cycle keeps your data.

## Managing containers and volumes

- `docker compose --project-directory srcs -f srcs/docker-compose.yml ps` — container status.
- `docker compose --project-directory srcs -f srcs/docker-compose.yml logs -f <service>` — follow a service's logs.
- `docker compose --project-directory srcs -f srcs/docker-compose.yml exec <service> sh` — open a shell inside a running container.
- `docker volume ls` / `docker volume inspect <name>` — inspect the named volumes (`mysql`, `wordpress`).

## Where data lives and how it persists

MariaDB's data and the WordPress files are each a Docker named volume (`mysql` and `wordpress` in `srcs/docker-compose.yml`), configured with a `local` driver bound to a host path rather than Docker's default volume storage — so the actual files live at `/home/speterse/data/mysql` and `/home/speterse/data/wordpress` on the host, and survive containers being stopped, removed, and rebuilt. The only thing that erases them is `make clean`.
