MARIADB_MOUNT_DIR = /home/speterse/data/mysql
WP_MOUNT_DIR = /home/speterse/data/wordpress

compose-up: build
	docker compose --project-directory srcs -f srcs/docker-compose.yml up -d

compose-down:
	docker compose --project-directory srcs -f srcs/docker-compose.yml down --rmi all

build:
	mkdir -p $(MARIADB_MOUNT_DIR) $(WP_MOUNT_DIR)
	docker compose --project-directory srcs -f srcs/docker-compose.yml build

clean: compose-down
	rm -rf $(MARIADB_MOUNT_DIR)/*
	rm -rf $(WP_MOUNT_DIR)/*


.PHONY: compose-up compose-down build clean