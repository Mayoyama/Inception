FROM debian:bookworm-slim

RUN apt-get update && apt-get -y install vsftpd

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo /usr/sbin/nologin >> /etc/shells

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

