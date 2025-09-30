# Dockerized Avorion dedicated server in an Ubuntu 24.04 container

[![GitHub Actions](https://github.com/AndrewSav/avorion-docker/actions/workflows/main.yml/badge.svg)](https://github.com/AndrewSav/avorion-docker/actions)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/andrewsav/avorion?sort=semver)](https://hub.docker.com/r/andrewsav/avorion/tags)

This is not an official project and I'm not affiliated with developers or publishers of the game. There is not a lot of external documentation on the dedicated server but once server is started there is `server.ini - readme.txt` in the saves directory corresponding to your  galaxy name that documents most of the settings. Also if the server binary is run with the `/h` switch it prints out the possible command line arguments.

## Environment Variables

| Name                  | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| SERVER_ARGS           | This is the command line arguments for the server binary. You need at least `--galaxy-name` switch here, which names the directory inside `/root/.avorion/galaxies` in the container with the game saves and settings. Run the server binary with the `/h` switch to get the lost of all supported arguments. |
| SKIP_UPDATE           | By default, the game server will be updated with `steamcmd` on the container startup. Set this to 1, to avoid this. |
| IGNORE_UPDATE_FAILURE | By default, if steam update fails, the container will exit, which, in combination with `unless-stopped` docker restart policy will cause a retry. If you'd rather run the previous version of the server in this case, set this to 1 |

## Ports


| Exposed Container port | Type |
| ------------------------ | ------ |
| 27000            | TCP |
| 27003 | UDP |
| 27020 | UDP |
| 27021 | UDP |

In order for others to connect to your server you will most likely need to configure port forwarding on your router for all the ports above. See below for considerations for changing the ports. *Note: RCON port is not mentioned here, since it's optional, and disabled by default. Feel free to configure it to suite your needs*

## Volumes


| Volume             | Container path              | Description                             |
| -------------------- | ----------------------------- | ----------------------------------------- |
| Server install path | /server   | the server files are downloaded into this directory |
| Saves/settings top directory | /root/.avorion | settings files are created here on the first start. there will be two subdirectories here: `backups`  and `galaxies`. Inside the latter there will be a subdirectory with your galaxy name which will have your saves and settings |
| `Steamcmd` binaries directory | /root/.local/share/Steam | this is not a volume, but you can map it to avoid downloading steamcmd binary on each container start up |

## Starting the server

In the folder containing `docker-compose.yml` run

```bash
docker compose up -d --force-recreate
```

You can watch the logs with:

```bash
docker compose logs -f
```

*Note: this readme assumes that you are using supplied `docker-compose.yml` to start the server. Some parts of this readme may be inaccurate if your settings differ from the provided.*

## Accessing server console

To attach to the console run:

```
docker compose attach avorion
```

Then hit `enter` once or twice.

To detach, press:

```
CTRL+p CTRL+q
```

This may or may not work depending on your terminal, and on whether or not you are using `ssh`. This can be awkward to use, because arrows and even backspace does not seem to be supported, use the in-game console wherever you can. `/admin -a --name your_steam_name --id your_steamID64` Will add you to the admins list. You can lookup your steam id at <https://steamid.io/>.

## Server configuration

Once the server fully started for the first time it will create a subdirectory under `/root/.avorion/galaxies` in the container. That subdirectory will have the game saves and settings. The changes to the setting files can be overwritten by the server if it's running, so before editing stop the container with `docker compose down`.

Edit the files to your liking, in particular you might want to change the server name and/or description in `server.ini`, and restart the container:

```bash
docker compose up -d --force-recreate
```

Logs are found in the same directory mentioned above.

You can now connect to your server from the game (providing that the port forwarding is set up correctly).

*Note: read the official notes linked at the top of this README, they will tell you how to set up a password, copy the game world from your single player playthrough and more*

## Connecting to the server

You can either find your server in the "Browse Servers" section in game to join (if you gave it a unique name), or you can use "Join via IP". In the latter case if you customised the port numbers, you should also specify the port along with your server IP, which you passed to the `--query-port` command line switch of the server binary. 

## Updating the server

Restart the container. It will check steam for the newer server version on start and update if required. My preferred method of restarting is running `docker compose up -d --force-recreate` but simple `docker restart avorion` would suffice. 

## Additional Information

## Changing ports

If you change ports in `docker-compose.yaml`. If you do remember:

- The ports the server binary listens on, that are passed via command line switches, should match the external port numbers exposed to internet, other players and steam lobby is going to connect on. If they do not, your server will not appear in the server browsers (although you still will be able to connect via IP/Port)
- Port can be mapped on several levels, e.g in the docker compose `ports` mapping and on your router/firewall. This means that the docker compose configuration may or may not reflect the actual external port number exposed to internet, depending on your other configuration
- The ports in the server arguments should always match the container mapped ports, so if you change a port you for sure will change it in two places in docker compose (the server arguments port and the docker port inside the container) at least, but more likely in three (also in the docker exposed port outside the container)

Here is an abridged example:

```yaml
    environment:
      SERVER_ARGS: >-
        --galaxy-name avorion_galaxy
        --port 30000
        --query-port 30001
        --steam-query-port 30002
        --steam-master-port 30003
    ports:
      - 30000:30000
      - 30001:30001/udp
      - 30002:30002/udp
      - 30003:300003/udp
```

### Port forwarding

Detailed port forwarding guide is out of scope of this document, there are a lot of variations between routers in how this is done. However here is a few important point to keep in mind:

- Pay attention to which protocol TCP or UDP you forward your ports, the table at the top of this document specifies them.
- It is possible, that the server is accessible from the internet but not from the same (home) network where your server is in. This is called a hairpin NAT problem. Either google how to configure it on your router (if it supports it), or use local IP address for connecting to the server within the same network (as opposed to your external IP address).
- Some internet providers employ [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT). If yours does, you won't be able to make your server accessible externally, unless you and other users use a VPN or a tunneling service such as <https://playit.gg/> (this is not an endorsement, I have never used this service myself).

## About this docker image

See [APPROACH.md](https://github.com/AndrewSav/moria-docker/blob/main/APPROACH.md)

## Credits

- https://github.com/rfvgyhn/docker-avorion
