Simple Killing Floor Server (Docker / Podman)
=============================================

Dockerized Killing Floor dedicated server with SteamCMD, WebAdmin, and runtime configuration.

Building from source is necessary to enable web UI and authenticate with steam.

Uses the steamcmd docker image from [cm2network/steamcmd](https://hub.docker.com/r/cm2network/steamcmd)

**Quick Start**
---------------
_I STRONGLY RECOMMEND YOU READ FURTHER IF YOU ARE NOT FAMILIAR WITH DOCKER OR STEAMCMD_

If you know what you are doing this one-liner should be the fastest way to set things up:

```bash <(curl -s https://raw.githubusercontent.com/josh56432/killingfloor-docker/main/build.sh)```


Prerequisites
-------------

- Git (obviously)
- Docker / Podman
- X86 or X86_64 (i386 / amd64) debian based systems (IMPORTANT: aarch64 and riscv do not have a version of this steamcmd built for them) 
- A dedicated steam account to host the server

If you want support to be expanded to other OS distributions feel free to create a pull request :)

Minimum requirements:

- Intel Atom D525 / Celeron N2840 
- 500MB RAM
- 4GB Storage
- 10BASE-T capable NIC (10Mbps)

Or if you are absolutely stuck with a raspberry pi the Pi3B+ 1G should be powerful enough (just about) to run QEMU-i386 and host it there.
 
If you wish to host this for friends to connect either set a game password through the webUI, 
port forward the server through your router and share your public IP with them (if you have one from your ISP),
or alternatively host a wireguard server either on the same machine or on the LAN (beefier NIC required) and
create individual tunnels for each friend, this way you only need to port forward the wireguard port (default 51820).
I much prefer this method, since I imported the built image to kubernetes on the same cluster as a wg-easy instance.

Useful links:

- [qemu-system-i386 manpage](https://linuxcommandlibrary.com/man/qemu-system-i386)
- [wg-easy github](https://github.com/wg-easy/wg-easy)
- [wg-easy kubernetes guide](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Kubernetes)
 
Build
-----
```
git clone https://github.com/josh56432/killingfloor-docker.git
cd killingfloor-docker
sudo chmod +x build.sh
./build.sh
```
Or if you like to live life on the edge:

```bash <(curl -s https://raw.githubusercontent.com/josh56432/killingfloor-docker/main/build.sh)```

You'll be prompted for:
- Steam username/password
- Steam Guard code (after first build intentionally fails)

Run
---
```
docker run \
  -e ADMINUNAME=admin \
  -e ADMINPWD=yourpass \
  -e UIPORT=8075 \
  -p 7707-7708:7707-7708/udp \
  -p 7717:7717/udp \
  -p 8075:8075 \
  -p 20560:20560/udp \
  -p 28852:28852/udp \
  kfserver
```
Or with --net=host (no port mapping needed):

```docker run --net=host -e ADMINUNAME=admin -e ADMINPWD=pass kfserver```

To use podman simply replace "docker" with "podman" it should be identical.

Environment Variables
---------------------

| Variable     | Default   | Description           |
|--------------|-----------|-----------------------|
| UIPORT       | 8075      | WebAdmin port         |
| ADMINUNAME   | admin     | WebAdmin username     |
| ADMINPWD     | changeme  | WebAdmin password     |

Mods & Addons
-------------

To tweak the KillingFloor.ini file (there is a default one in ./config) use a basic text editor to edit
the file then re-run build.sh to install it.

To add mods / addons download the mod package and find the folders respective to the ones in ./addons
then simply put the correct files in the correct folders. Once they are all copied over, and the relevant setups are performed, re-run build.sh to install

There are README files for reference in the folders.

If you need a default config file to edit it and the mod package doesn't provide a full default, you can copy and paste
the generated configs by doing the following:

```
docker ps // find the name of the server running kfserver
docker exec -it <NAME> /bin/bash
ls
```
This will list all config files in the System folder (where KillingFloor.ini lives)

```
cat <CONFIGNAME>
```
This will display the contents of the config, then copy and paste them into a new file in the ./config
folder. On run the server will install your custom files.

Ports
-----

| Ports               | Protocol | Purpose          |
|---------------------|----------|------------------|
| 7707-7708           | UDP      | Game clients     |
| 7717                | UDP      | LAN discovery    |
| 8075                | TCP      | WebAdmin         |
| 20560, 28852        | UDP      | Steam/GameSpy    |


Notes
-----

- Defaults to container cmd installed on system (docker / podman) for build command, if you have both you will be prompted to choose one.
- Create a separate Steam account for the server. Do not use your main account.
- The first build fails intentionally – Steam emails a guard code. Enter it when prompted.
- WebAdmin is auto‑configured at container startup to default to localhost:8075

Support
-------
## ☕ Support This Project

<a href="https://www.buymeacoffee.com/josh56432" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40" />
</a>

