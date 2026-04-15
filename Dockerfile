FROM docker.io/cm2network/steamcmd:latest

ARG USER
ARG PASS
ARG STEAMGUARD=XXXXX   # dummy default

RUN mkdir /home/steam/server

# Install the game server files
RUN ./steamcmd.sh +force_install_dir /home/steam/server \
    +login "${USER}" "${PASS}" "${STEAMGUARD}" \
    +app_update 215360 +quit

WORKDIR /home/steam/server/System

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
