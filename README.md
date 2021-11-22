# Dwarf Fortress within docker

Run [Dwarf Fortress](https://www.bay12games.com/dwarves/) inside a Docker container and have it accessible through the browser.

![image](https://user-images.githubusercontent.com/26963810/143337607-babd5779-b1e5-4eed-96fc-b3e16beba00a.png)

## Resource usage

As per to its [wiki page](https://www.dwarffortresswiki.org/index.php/DF2014:System_requirements#RAM) you should expect the game to allocate between 300MB to 700MB on medium regions and never more than 1GB.

However, when running a container from this image you can expect the resource usage on medium region to go up to ~1GB. That is because on top of the game itself there's also xvfb maintaining an in-memory representation of the _Display_ together with x11vnc and noVNC making constant use of it.

## NO DFHack

This image only supports the vanilla game and thus [DFHack](https://github.com/DFHack/dfhack) is not included with it nor will it run even if added. Any type of customization supported by the vanilla game can still be added, for example, fonts and tilesets ([one included](https://dwarffortresswiki.org/index.php/File:Kelora_16x16_diagonal-clouds.png) within this repo and activated by default).

It is however in my plans to give it a go at adding support for DFHack.

## What's included in the image

This image runs:
- Xvfb - Virtual frame buffer X11 server. Creates a virtual Display.
- x11vnc - A VNC server that interacts with X displays.
- noNVC - A JavaScript VNC client library. Allows to connects to a VNC server through any browser.
- Dwarf Fortress - the GUI application we intend to run.

This is built from the base image `debian:buster` and has a final image size of ~540MB.

## Build arguments

The image can be customized with the arguments:
 - **DF_VERSION** version of Dwarf Fortress to download. Defaults to "47_05" (latest).
 - **TILESET** name of tileset to use. Defaults to "Kelora_16x16_diagonal-clouds.png" which is included in the repo.
 - **PLAY_INTRO** whether to play the intro movie or not. Defaults to "NO".

## Environment variables

**`DISPLAY_DIMENSIONS`** sets the dimensions for the virtual display created by Xvfb and has the format: \<PIXEL WIDTH>**x**\<PIXEL HEIGHT>**x**\<PIXEL DEPTH>

Example value: "**1440x763x24**"

The best setting is to fill all free inner space on a browser window. Use `window.innerWidth` and `window.innerHeight` on the console to find these values for your screen.

## Volumes

For the game save files to persist across container restarts it's necessary to mount a host directory to where the game saves these files inside the container.
**`<host_directory>:/home/df/df_linux/data/save/`**

## Ports

We want to access noVNC inside the container but from within our browser so we will have to map the port `8080` to an available port of the host.

## Example of docker commands

Build an image with a different tileset (needs to be copied into the Tilesets folder) and without skipping the intro movie of the game.
```
docker build \
    --build-arg TILESET=my_tileset.png \
    --build-arg PLAY_INTRO=YES \
    . --tag=dwarffortress
```

Then, to run a container:
```
docker run \
    -e 'DISPLAY_DIMENSIONS'='1440x763x24' \
    -v '/mnt/user/appdata/dwarffortress/':'/home/df/df_linux/data/save/':'rw' \
    -p 9650:8080
    dwarffortress
```

## Logs

When inspecting the container logs you will find all the the processes output bundled together. Although this can make it more confusing against it's alternative - a log file per process inside the container - for the majority of times it's quicker to find the cause of a problem this way.

## References

https://medium.com/@pigiuz/hw-accelerated-gui-apps-on-docker-7fd424fe813e
