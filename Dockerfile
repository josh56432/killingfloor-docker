FROM docker.io/cm2network/steamcmd:latest

ARG HOSTUSER
ARG HOSTPASS
ARG STEAMGUARD

RUN mkdir /home/steam/server

RUN ./steamcmd.sh +force_install_dir /home/steam/server \
    +login "${HOSTUSER}" "${HOSTPASS}" "${STEAMGUARD}" \
    +app_update 215360 +quit


COPY ./addons/ /home/steam/server/
RUN rm /home/steam/server/README

RUN mkdir /home/steam/custom_config
COPY ./config /home/steam/custom_config
RUN rm /home/steam/custom_config/README

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER root
WORKDIR /home/steam/server/System

ENTRYPOINT ["/entrypoint.sh"]
