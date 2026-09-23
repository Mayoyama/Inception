# User Documentation

## Services

The stack provides:

- **WordPress** — the website and its admin panel, at `https://speterse.42.fr`.
- **MariaDB** — the database behind WordPress (not directly reachable from outside the stack).
- **NGINX** — the entry point for the website, serving it over HTTPS (TLSv1.2/1.3) on port 443.

Bonus services:

- **Adminer** — a web interface for browsing the WordPress database, at `http://127.0.0.1:8080`.
- **Portainer** — a web interface for managing the containers, at `https://127.0.0.1:9443`.
- **FTP** — access to the WordPress files, at `127.0.0.1:2121`.
- **Static site** — a plain HTML showcase page, at `http://127.0.0.1:8082`.
- **Redis** — the object cache for WordPress, running inside the stack (not reachable from outside).

## Starting and stopping

From the repository root:

- `make`/`make compose-up` — builds the images and starts every container in the background.
- `make compose-down` — stops the containers and removes the images built for this project.

Your WordPress content and database survive being stopped and started again — see "Where data lives" in DEV_DOC.md.

## Accessing the site and admin panel

- Website: `https://speterse.42.fr`
- WordPress admin panel: `https://speterse.42.fr/wp-admin`

Since the TLS certificate is self-signed, your browser will warn you the first time — this is expected for this project and can be accepted. Portainer uses its own self-signed certificate and shows the same warning.

## Accessing the bonus services

- **Adminer** — open `http://127.0.0.1:8080` and log in with server `mariadb`, username `MYSQL_USER` (from `srcs/.env`), password from `secrets/db_password.txt`, and database `MYSQL_DATABASE`.
- **Portainer** — open `https://127.0.0.1:9443`. On first visit it asks you to create an admin account; this has to be done within a few minutes of the container starting, otherwise Portainer locks setup and the container must be restarted. The account is not persisted, so it has to be created again after the container is recreated.
- **Static site** — open `http://127.0.0.1:8082`. It's a single static page with no login.
- **FTP** — connect with an FTP client to `127.0.0.1:2121` using `FTP_USER` (from `srcs/.env`) and the password in `secrets/ftp_user_password.txt`. You land in the WordPress files and can upload, download and edit them. For example, to list the files:

  ```
  curl ftp://<FTP_USER>:<password>@127.0.0.1:2121
  ```

## Credentials

- Usernames (`WP_ADMIN_USER`, `WP_USER`, `MYSQL_USER`, `FTP_USER`) are set in `srcs/.env`.
- Passwords are never stored in `.env` or in git — they live as plain-text files in the `secrets/` folder at the repository root (`wp_admin_password.txt`, `wp_user_password.txt`, `db_password.txt`, `db_root_password.txt`, `ftp_user_password.txt`), which only exists locally on the machine running the project.
- The administrator account's username is not allowed to contain "admin" or "administrator", per the project's rules.
- Passwords are only applied when an account is first created, so editing a file in `secrets/` afterwards has no effect on its own:
  - **FTP** — the FTP user is recreated with every new container, so `make compose-down` followed by `make` picks up the new password.
  - **MariaDB and WordPress** — their accounts are only created when the data volumes are empty, so the new password only applies after `make clean` followed by `make`. This erases the database and the WordPress files.

## Checking the services are running

`docker compose --project-directory srcs -f srcs/docker-compose.yml ps` lists every container and its status — all of them should show as `Up`. To look at what a specific service is doing, use `docker compose --project-directory srcs -f srcs/docker-compose.yml logs <service>` (e.g. `logs wordpress`).
