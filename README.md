# Inception

*This project has been created as part of the 42 curriculum by speterse.*

## Description

Inception sets up a small self-hosted web infrastructure entirely with Docker, without relying on any pre-built images (aside from the base Alpine/Debian layer). Each service — NGINX, WordPress with php-fpm, and MariaDB — runs in its own container, built from a hand-written Dockerfile, and is wired together with Docker Compose. A set of bonus services (Redis, FTP, a static site, Adminer, and Portainer) extends the stack further.

All containers are built from a penultimate-stable Debian base image. Only NGINX is exposed to the outside world, over port 443 using TLSv1.2/TLSv1.3, and it is the sole entrypoint into the infrastructure. WordPress and MariaDB persist their data in Docker named volumes, mounted on the host at `/home/<login>/data`.

### Design choices

- **Virtual Machines vs Docker** — a VM virtualizes an entire OS (kernel, drivers, full filesystem), which is heavier and slower to provision but gives complete isolation. Docker containers share the host kernel and only package the application and its dependencies, which is far lighter and faster to build/start, at the cost of weaker isolation than a full VM. This project runs multiple Docker containers *inside* one VM: the VM provides the isolated environment the subject requires, and Docker provides fast, reproducible service isolation within it.
- **Secrets vs Environment Variables** — environment variables (via `.env`) are readable by anything with access to the container's environment (e.g. `docker inspect`, `/proc/<pid>/environ`) and can end up logged or exposed accidentally. Docker secrets are mounted as files under `/run/secrets/`, only visible inside the container they're attached to, and never appear in `docker inspect` output. `.env` is used here for non-sensitive configuration (usernames, domain name, database name); actual passwords are stored as secrets and read from `/run/secrets/*` at container startup.
- **Docker Network vs Host Network** — `network: host` would drop container network isolation entirely, giving every container direct access to the host's network stack and exposing all their ports without control. A dedicated bridge network (`inception`) keeps containers isolated from the host network, lets them resolve each other by service name, and only exposes the ports explicitly published in `docker-compose.yml`.
- **Docker Volumes vs Bind Mounts** — a bind mount points directly at a host path and depends on that path/permissions already existing correctly on the host. A named volume is managed by Docker itself, portable across environments, and only requires specifying where the data should live on the host — which is exactly what's needed for two persistent, Docker-managed datastores (MariaDB's database and WordPress's files) without depending on manual host setup.

## Services

| Service    | Purpose                                   |
|------------|--------------------------------------------|
| nginx      | TLS termination, sole entrypoint (443)     |
| wordpress  | WordPress + php-fpm                        |
| mariadb    | Database                                   |
| redis      | Object cache for WordPress                 |
| ftp        | vsftpd server over the WordPress volume    |
| static-site| Plain HTML/CSS showcase site               |
| adminer    | Database administration UI                 |
| portainer  | Docker container management UI             |

## Instructions

1. Clone the repository onto a Debian-based VM.
2. Create a `secrets/` directory at the repo root containing the required `*.txt` password files (see `DEV_DOC.md`), and a `srcs/.env` file with the required variables. Neither is committed to the repository.
3. From the repo root, run:
   ```
   make
   ```
   This builds every Docker image from its own Dockerfile and starts the stack via `docker-compose.yml`.
4. Point the domain name (e.g. `<login>.42.fr`) at the machine running the stack.
5. Visit `https://<login>.42.fr` in a browser.

See `USER_DOC.md` for day-to-day usage (starting/stopping, accessing the site and admin panel, credentials) and `DEV_DOC.md` for full environment setup and development commands.

## Resources

**NGINX / TLS**
- https://hub.docker.com/_/nginx
- https://nginx.org/en/docs/beginners_guide.html#conf_structure
- https://youtu.be/RdzfnAcrLtU?si=rGsgAgpdf51vas7D
- https://nagasudhir.blogspot.com/2025/10/create-self-signed-ssl-certificate-with.html

**Portainer**
- https://www.bluehost.com/blog/portainer-vs-docker/

**Adminer**
- https://hub.docker.com/_/adminer/
- https://www.adminer.org/#extras

**Redis**
- https://hub.docker.com/_/redis

**vsftpd**
- https://security.appspot.com/vsftpd/vsftpd_conf.html

### AI usage

AI (Claude) was used as a debugging and troubleshooting aid throughout the project, not to author the infrastructure itself — all Dockerfiles, configuration files, and compose service definitions were written manually. Specific uses:

- Diagnosing the FTP (vsftpd) container's crash-loop, tracing it to an unresolvable `pasv_address` hostname, and identifying a follow-up PAM/`/etc/shells` login issue.
- Diagnosing why the site was unreachable from inside the VM, tracing it to a WordPress `siteurl`/`home` database value that didn't match the actual NAT setup.
- Diagnosing a stray `index.nginx-debian.html` file, tracing it to the NGINX and WordPress containers sharing a named volume rather than NGINX being installed where it shouldn't be.
- Troubleshooting a VS Code Remote-SSH connection failure (malformed local SSH config).
- Drafting this README's structure and wording from the project's own documented setup and decisions.
