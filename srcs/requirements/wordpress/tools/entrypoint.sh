#!/bin/bash
set -e

until mysqladmin ping -h mariadb o--silent; do
	sleep 1
done

if [ ! -d "/var/lib/mysql/mysql" ]; then
	DB_PASSWORD=$(cat /run/secrets/db_password)
	DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
	
	wp core download --path=/var/www/html
	wp config create --dbname ${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${DB_PASSWORD} --dbhost=mariadb --path="/var/www/html"
	

fi

exec php-fpmd8.2 -F
