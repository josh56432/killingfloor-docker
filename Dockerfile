FROM docker.io/cm2network/steamcmd:latest

ARG USER
ARG PASS
ARG STEAMGUARD

RUN mkdir /home/steam/server

# Install the game server files
RUN ./steamcmd.sh +force_install_dir /home/steam/server \
    +login "${USER}" "${PASS}" "${STEAMGUARD}" \
    +app_update 215360 +quit

WORKDIR /home/steam/server/System

COPY ./addons/ /home/steam/server/
DELETE /home/steam/server/README

RUN mkdir /home/steam/custom_config
COPY ./config /home/steam/custom_config
DELETE /home/steam/custom_config/README

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
