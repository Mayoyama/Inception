#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	mysqld_safe --datadir=/var/lib/mysql &

	until mysqladmin ping --silent; do
		sleep 1
	done

	DB_PASSWORD=$(cat /run/secrets/db_password)
	DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

	mysql -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
		CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
EOSQL

	mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

fi

exec mysqld_safe --datadir=/var/lib/mysql
