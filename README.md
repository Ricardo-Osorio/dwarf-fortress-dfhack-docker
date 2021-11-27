# Dwarf Fortress within docker <img title="docker-icon" width="55" height="40" src="https://www.docker.com/sites/default/files/d8/styles/role_icon/public/2019-07/Moby-logo.png">

Run [Dwarf Fortress](https://www.bay12games.com/dwarves/) in a Docker container and play in the browser!

![image](https://user-images.githubusercontent.com/26963810/143337607-babd5779-b1e5-4eed-96fc-b3e16beba00a.png)

## Versions

This repo contains two versions of Dwarf Fortress (v47.05) installations, each packaged with different settings and extras:
 - game packed with dfhack, TWBT, Spacefox's tileset and embark profiles (`main` branch)
 - vanilla game with the "Kelora_16x16_diagonal-clouds" tileset and embark profiles (`vanilla` branch)

## Resource usage

As per to its [wiki page](https://www.dwarffortresswiki.org/index.php/DF2014:System_requirements#RAM) and when installed directly on your machine, you should expect the game to allocate between 300MB to 700MB RAM on medium regions and never more than 1GB.

However, when running a container from this image you can expect the resource usage on medium region to go up to ~1GB. That's because on top of the game itself there's also xvfb maintaining an in-memory representation of the _Display_ together with x11vnc and noVNC making constant use of it so that much is to be expected.

## The stack of software making this posible

This image runs the following software:
- [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) - Virtual frame buffer X11 server. Creates a virtual Display.
- [x11vnc](https://wiki.archlinux.org/title/X11vnc) - VNC server that interacts with X displays.
- [noNVC](https://novnc.com/info.html) - JavaScript VNC client library. Allows to connects to a VNC server through any browser.
- [Dwarf Fortress](https://www.bay12games.com//dwarves/) - GUI application we intend to run.

All downloaded at runtime and built from `debian:buster`. In total the image size is around 540MB.

## The image

The image can be customized with the runtime arguments:
 - **DF_VERSION** version of Dwarf Fortress to download. Defaults to "47_05" (latest).
 - **TILESET** name of tileset to use. Defaults to "Kelora_16x16_diagonal-clouds.png", which is included in the repo.
 - **PLAY_INTRO** whether to play the intro movie or not. "YES"/"NO", defaults to "NO"

And environment variables:
 - **DISPLAY_DIMENSIONS** dimensions for the virtual display created by Xvfb. Example being "**1440x763**".

If you decide to build the image yourself, be aware that it takes a long time to build.

The images are also available on [DockerHub here](https://hub.docker.com/r/ricosorio/dwarffortress/).

### Volumes

For the game save files to persist across container restarts it's necessary to mount a host directory to where the game saves these files inside the container.
**`<host_directory>:/home/df/df_linux/data/save/`**

You can also mount the Dwarf Fortress and config files between host and container if you want to continue using your own configurations, with your own settings.

### Ports

We want to access noVNC inside the container but from within our browser so we will have to map the port **`8080`** to any free port on the host machine.

## Example of the docker commands

To build an image that won't skip the intro movie and uses a different tileset (needs to be copied into the Tilesets folder):
```
docker build \
    --build-arg TILESET=my_tileset.png \
    --build-arg PLAY_INTRO=YES \
    . --tag=dwarffortress
```

Then, to run a container:
```
docker run \
    -e 'DISPLAY_DIMENSIONS'='1440x763' \
    -v '/home/user/games/dwarffortress/':'/home/df/df_linux/data/save/':'rw' \
    -p 9650:8080
    dwarffortress
```

## The ugly bits

The connection between your browser and noVNC is **unencrypted** and it's not protected by any kind of authentication/authorization. It is not meant for use over the internet. Use at your own risk.

## Logs

When inspecting the container logs you will find all the the processes output bundled together. Although this can make it more confusing against it's alternative - a log file per process inside the container - for the majority of times it's quicker to find the cause of a problem this way.

## References

https://medium.com/@pigiuz/hw-accelerated-gui-apps-on-docker-7fd424fe813e