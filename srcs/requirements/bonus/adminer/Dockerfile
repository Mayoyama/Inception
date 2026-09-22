FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    php-mbstring \
    php-cli \
    php-mysql

WORKDIR /opt/adminer

RUN curl -L https://github.com/vrana/adminer/releases/download/v6.1.0/adminer-6.1.0-mysql.php -o adminer.php

CMD ["php", "-S", "0.0.0.0:8080", "adminer.php"]
