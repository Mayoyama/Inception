#!/bin/bash
set -e

until mysqladmin ping -h mariadb --silent; do
	sleep 1
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
	DB_PASSWORD=$(cat /run/secrets/db_password)
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
	WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
	
	wp core download --path=/var/www/html
	wp config create --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${DB_PASSWORD}" --dbhost=mariadb --path="/var/www/html"
	wp core install --path=/var/www/html \
		--url="${DOMAIN_NAME}" \
		--title="${WP_ADMIN_USER}'s wordPress" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_ADDRESS}"
	wp user create "${WP_USER}" "${WP_USER_ADDRESS}" --role=author --user_pass="${WP_USER_PASSWORD}" --path=/var/www/html

fi

exec php-fpm8.2 -F
