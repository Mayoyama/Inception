# User Documentation

## Services

The stack is reachable at `https://speterse.42.fr` and provides:

- **WordPress** — the website and its admin panel, at the domain above.
- **MariaDB** — the database behind WordPress (not directly reachable from outside the stack).
- **NGINX** — the only entry point into the stack, serving everything over HTTPS (TLSv1.2/1.3) on port 443.

Bonus services (in progress): a **Redis** cache for WordPress, an **FTP** server for the WordPress files, a plain **static showcase site**, **Adminer** for browsing the database, and **Portainer** for managing the containers.

## Starting and stopping

From the repository root:

- `make`/`make compose-up` — builds the images and starts every container in the background.
- `make compose-down` — stops the containers and removes the images built for this project.

Your WordPress content and database survive being stopped and started again — see "Where data lives" in DEV_DOC.md.

## Accessing the site and admin panel

- Website: `https://speterse.42.fr`
- WordPress admin panel: `https://speterse.42.fr/wp-admin`

Since the TLS certificate is self-signed, your browser will warn you the first time — this is expected for this project and can be accepted.

## Credentials

- Usernames (`WP_ADMIN_USER`, `WP_USER`) are set in `srcs/.env`.
- Passwords are never stored in `.env` or in git — they live as plain-text files in the `secrets/` folder at the repository root (`wp_admin_password.txt`, `wp_user_password.txt`, `db_password.txt`, `db_root_password.txt`), which only exists locally on the machine running the project.
- The administrator account's username is not allowed to contain "admin" or "administrator", per the project's rules.

## Checking the services are running

`docker compose --project-directory srcs -f srcs/docker-compose.yml ps` lists every container and its status — all of them should show as `Up`. To look at what a specific service is doing, use `docker compose --project-directory srcs -f srcs/docker-compose.yml logs <service>` (e.g. `logs wordpress`).
