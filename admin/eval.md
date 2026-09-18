# Inception — Evaluation Checklist

https://42evals.slddl.ovh/Cursus/Inception/

## Before the evaluation (on the VM)
- [ ] Confirm Docker starts on boot: `systemctl enable docker` (the persistence test reboots the VM, then re-runs docker compose)
- [ ] Rehearse the evaluator's reset, then a clean build:
  ```
  docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q)
  make
  ```
- [ ] Confirm `speterse.42.fr` resolves to the VM's local IP (e.g. via /etc/hosts)
- [ ] Double-check `WP_ADMIN_USER` in `.env` does not contain "admin"/"administrator" in any form — hard fail if it does

## General checks (evaluator does these first)
- [ ] `srcs/` at repo root, `Makefile` at repo root
- [ ] `docker-compose.yml`: no `network: host`, no `links:`, has a `networks:` section
- [ ] No `--link` anywhere in the Makefile or any script
- [ ] No `tail -f`, background commands, or bare `bash`/`sh` in any ENTRYPOINT/CMD
- [ ] No infinite loops in any script (`sleep infinity`, `tail -f /dev/null`, etc.)
- [ ] `make` runs cleanly, no crashes

## Simple setup
- [ ] NGINX reachable on port 443 only
- [ ] `http://speterse.42.fr` must fail to connect entirely (not redirect)
- [ ] Self-signed TLS cert is used and presented
- [ ] `https://speterse.42.fr` shows the real WordPress site, not the install page

## Be ready to explain
- [ ] How Docker and docker compose work
- [ ] Difference between a Docker image used with vs. without compose
- [ ] Benefit of Docker vs VMs
- [ ] Why this directory structure makes sense
- [ ] What docker-network does
- [ ] How to log into MariaDB

## Per-service checks

**NGINX**
- [ ] Dockerfile present, not empty
- [ ] `docker compose ps` shows the container
- [ ] Port 80 is unreachable from outside
- [ ] TLS 1.2/1.3 demonstrated

**WordPress**
- [ ] Dockerfile present, no nginx installed in it
- [ ] `docker volume inspect wordpress` shows a path under `/home/speterse/data/`
- [ ] Post a comment as the regular WP user (WP_USER)
- [ ] Sign in as admin, edit a page, confirm the change shows on the live site

**MariaDB**
- [ ] Dockerfile present, no nginx installed in it
- [ ] `docker volume inspect mysql` shows a path under `/home/speterse/data/`
- [ ] Confirm the database is not empty

## Persistence
- [ ] Reboot the VM
- [ ] Re-run `make` (or docker compose up) — should not need a rebuild from scratch
- [ ] WordPress + MariaDB come back with prior data/edits intact

## Possible live-modification request (Chapter IX)
Not a fixed requirement — the evaluator may ask for a small on-the-spot change during the defense to check real understanding (e.g. moving nginx off port 443). If asked to change the port:
- update `listen` in `default.conf`
- update `ports:` in `docker-compose.yml`
- rebuild/restart nginx
- verify with `curl -k https://speterse.42.fr:<newport>/`

## Bonus (only evaluated if mandatory is perfect)
- [ ] Each bonus service actually works, not just present
- [ ] Be ready to justify the "service of your choice" pick (Portainer)

## Still outstanding before the eval
- [ ] README.md, including the 4 required comparisons: VM vs Docker, Secrets vs Env vars, Docker Network vs Host Network, Volumes vs Bind Mounts
- [ ] Bonus services not yet built (redis, ftp, static-site, adminer, portainer)
- [ ] VM not set up yet — needed to actually run any of the above
