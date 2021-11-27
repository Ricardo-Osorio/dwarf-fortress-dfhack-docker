# Dwarf Fortress within docker <img title="docker-icon" width="55" height="40" src="https://www.docker.com/sites/default/files/d8/styles/role_icon/public/2019-07/Moby-logo.png">

Run [Dwarf Fortress](https://www.bay12games.com/dwarves/) in a Docker container and play in the browser!

![image](https://user-images.githubusercontent.com/26963810/143682084-fb4769e1-a8f0-4ddf-a4c5-8e0e3e2db6da.png)

## Versions

This repo contains two versions of Dwarf Fortress (v47.05) installations, each packaged with different settings and extras:
 - game packed with dfhack, TWBT, Spacefox's tileset and embark profiles (`main` branch)
 - vanilla game with the "Kelora_16x16_diagonal-clouds" tileset and embark profiles (`vanilla` branch)

## Resource usage

As per to its [wiki page](https://www.dwarffortresswiki.org/index.php/DF2014:System_requirements#RAM) and when installed directly on your machine, you should expect the game to allocate between 300MB to 700MB RAM on medium regions and never more than 1GB.

However, when running a container from this image you can expect the resource usage on medium region to go up to ~1.40GB. That's because on top of the game itself there's also xvfb maintaining an in-memory representation of the _Display_ together with x11vnc and noVNC making constant use of it and dfhack so that much is to be expected.

## The stack of software making this posible

This image runs the following software:
- [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) - Virtual frame buffer X11 server. Creates a virtual Display.
- [x11vnc](https://wiki.archlinux.org/title/X11vnc) - VNC server that interacts with X displays.
- [noNVC](https://novnc.com/info.html) - JavaScript VNC client library. Allows to connects to a VNC server through any browser.
- [Dwarf Fortress](https://www.bay12games.com//dwarves/) - GUI application we intend to run.
- [DFHack](https://github.com/DFHack/dfhack) - Memory editing library for Dwarf Fortress.

All downloaded at runtime and built from `debian:buster`. In total the image size is around 635MB.

## The image

The image can be customized with the runtime arguments:
 - **PLAY_INTRO** if you want to play the intro movie. "YES"/"NO", defaults to "NO".
 - **SHOW_FPS** if you want to see the game FPS. "YES"/"NO", defaults to "NO"

And environment variables:
 - **DISPLAY_DIMENSIONS** dimensions for the virtual display created by Xvfb. Example being "**1440x763**".

If you decide to build the image yourself, be aware that it takes a long time to build.

The images are also available on [DockerHub here](https://hub.docker.com/r/ricosorio/dwarffortress/).

### Volumes

For the game save files to persist across container restarts it's necessary to mount a host directory to where the game saves these files inside the container.
**`<host_directory>:/home/df/df_linux/data/save/`**

You can also mount the Dwarf Fortress and DFHack config files between host and container if you want to continue using your own configurations, with your own settings.

### Ports

We want to access noVNC inside the container but from within our browser so we will have to map the port **`8080`** to any free port on the host machine.

## Example of the docker commands

To build an image that won't skip the intro movie and shows the game FPS:
```
docker build \
    --build-arg PLAY_INTRO=YES \
    --build-arg SHOW_FPS=YES \
    . --tag=dwarffortress
```

Then, to run a container:
```
docker run \
    -e 'DISPLAY_DIMENSIONS'='1440x763' \
    -v '/home/user/games/dwarffortress/':'/home/df/df_linux/data/save/':'rw' \
    -p 9650:8080
    --security-opt=seccomp=unconfined
    dwarffortress
```

## The ugly bits

The connection between the browser and noVNC is **unencrypted** and it's not protected by any kind of authentication/authorization, therefore it's not meant to be used over the internet.

DFHack needs to be able to make a sys call which is, by default, blocked by Docker (`personality`). To overcome this restriction the container needs to run with and extra parameter `--security-opt=seccomp=unconfined`. While doing this fixes our problem it also presents a security risk. Read more [here](https://docs.docker.com/engine/security/seccomp/).

I am aware of two minor issues with this setup:
 - embarking on brand new fortresses the game will sometimes crash, however it quickly reboots and it won't happen twice on the same save file.
 - playing with `PLAY_INTRO=YES` forces the game to launch in window mode. Press F11 to switch to fullscreen (on macos you need to bind a new key). 

## Logs

When inspecting the container logs you will find all the the processes output bundled together. Although this can make it more confusing against it's alternative - a log file per process inside the container - for the majority of times it's quicker to find the cause of a problem this way.

## References

https://medium.com/@pigiuz/hw-accelerated-gui-apps-on-docker-7fd424fe813e
https://github.com/BenLubar/df-docker/blob/3c08fafbadfd60788e12d6a9e0e11c05f4ed751b/README.md
