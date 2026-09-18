FROM debian:bookworm

RUN apt-get update && apt-get install -y curl

RUN curl -L https://github.com/portainer/portainer/releases/download/2.45.1/portainer-2.45.1-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar -xzf portainer.tar.gz \
    && mv portainer /opt/portainer \
    && rm portainer.tar.gz

WORKDIR /opt/portainer

CMD ["./portainer"]