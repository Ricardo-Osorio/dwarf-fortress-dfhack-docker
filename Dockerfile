FROM debian:buster

# Set the locale.
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=C.UTF-8
ENV DISPLAY=:0

# Install dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
     # tools used
     xvfb \
     x11vnc \
     novnc \
     supervisor \
     # common libs needed
     wget \
     bzip2 \
     # game requirements
     libgtk2.0-0 \
     libncursesw5 \
     libopenal1 \
     libsdl-image1.2 \
     libsdl-ttf2.0-0 \
     libsdl1.2debian \
     libsndfile1 \
     libglu1-mesa

# House cleaning.
RUN rm -rf /var/lib/apt/lists/*

# Use vnc_lite.html, a minimalist version of the default page. Hide status bar.
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html && \
    sed -i 's/display:flex/display:none/' /usr/share/novnc/app/styles/lite.css

# Set up supervisord. Runs in the foreground.
COPY supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT [ "supervisord", "-c", "/etc/supervisor/supervisord.conf" ]

# Create and use a new user.
RUN groupadd df && useradd --create-home --gid df df
WORKDIR /home/df
USER df

# Download Dwarf Fortress. Defaults to 47.05.
ARG DF_VERSION=47_05
RUN wget http://www.bay12games.com/dwarves/df_${DF_VERSION}_linux.tar.bz2 -O - | tar -xj

# Fix common df issue of relying on old libstdc++ version.
RUN rm df_linux/libs/libstdc++.so.6

# Place tilesets where df can find them.
COPY Tilesets/* df_linux/data/art/

# Settings: fullscreen, no sound (doesn't work), skip intro and custom tileset.
ARG TILESET=Kelora_16x16_diagonal-clouds.png
ARG PLAY_INTRO=NO
RUN sed -i "s/WINDOWED:YES/WINDOWED:NO/" df_linux/data/init/init.txt && \
    sed -i "s/SOUND:YES/SOUND:NO/" df_linux/data/init/init.txt && \
    sed -i "s/INTRO:YES/INTRO:${PLAY_INTRO}/" df_linux/data/init/init.txt && \
    sed -i "s/FONT:curses_640x300.png/FONT:${TILESET}/" df_linux/data/init/init.txt && \
    sed -i "s/FULLFONT:curses_800x600.png/FULLFONT:${TILESET}/" df_linux/data/init/init.txt