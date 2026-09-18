#!/bin/bash
set -e


if ! id "${FTP_USER}" &>/dev/null; then
	FTP_USER_PASSWORD=$(cat /run/secrets/ftp_user_password)
	
	useradd -d /var/www/html -s /usr/sbin/nologin ${FTP_USER}
	echo "${FTP_USER}:${FTP_USER_PASSWORD}" | chpasswd

fi

exec /usr/sbin/vsftpd /etc/vsftpd.conf
