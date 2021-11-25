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
    # needed for downloads
    wget \
    bzip2 \
    unzip \
    # game requirements
    libgtk2.0-0 \
    libncursesw5 \
    libopenal1 \
    libsdl-image1.2 \
    libsdl-ttf2.0-0 \
    libsdl1.2debian \
    libsndfile1 \
    libglu1-mesa \
    # dfhack requirements
    python3 \
    python3-distutils \
    python3-tk \
    procps

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

# Download Dwarf Fortress.
RUN wget http://www.bay12games.com/dwarves/df_47_05_linux.tar.bz2 -O - | tar -xj

# Download dfhack. Use example config file.
RUN wget https://github.com/DFHack/dfhack/releases/download/0.47.05-r3/dfhack-0.47.05-r3-Linux-64bit-gcc-7.tar.bz2 -O - | tar -xj -C df_linux && \
    cp df_linux/dfhack.init-example df_linux/dfhack.init

# Download and install the dfhack plugin TWBT.
RUN wget https://github.com/thurin/df-twbt/releases/download/0.47.05-r3/twbt-6.xx-linux64-0.47.05-r3.zip && \
    unzip twbt-6.xx-linux64-0.47.05-r3.zip -d twbt && \
    rm twbt-6.xx-linux64-0.47.05-r3.zip && \
    cp twbt/0.47.05-r3/twbt.plug.so df_linux/hack/plugins/ && \
    cp twbt/transparent1px.png df_linux/data/art/ && \
    cp twbt/white1px.png df_linux/data/art/ && \
    cp twbt/shadows.png df_linux/data/art/ && \
    cp twbt/overrides.txt df_linux/data/init && \
    rm -r twbt

# House cleaning.
RUN rm -r df_linux/data/sound \
    df_linux/stonesense \
    df_linux/hack/plugins/stonesense.plug.so \
    df_linux/release\ notes.txt \
    df_linux/file\ changes.txt

# Embark profiles.
COPY --chown=df:df embark_profiles.txt df_linux/data/init/embark_profiles.txt

# Install Spacefox tileset with all TWBT variants.
RUN wget https://github.com/DFgraphics/Spacefox/archive/refs/tags/47.05a.tar.gz && \
    tar -xzf 47.05a.tar.gz && \
    rm 47.05a.tar.gz && \
    cp Spacefox-47.05a/data/art/* df_linux/data/art/ && \
    cp Spacefox-47.05a/data/init/* df_linux/data/init/ && \
    cp Spacefox-47.05a/raw/objects/* df_linux/raw/objects/ && \
    cp -r Spacefox-47.05a/raw/graphics/* df_linux/raw/graphics/ && \
    cp Spacefox-47.05a/data/twbt_art/* df_linux/data/art/ && \
    cp Spacefox-47.05a/data/twbt_init/* df_linux/data/init/ && \
    cp Spacefox-47.05a/raw/twbt_objects/* df_linux/raw/objects/ && \
    cp -r Spacefox-47.05a/raw/twbt_graphics/* df_linux/raw/graphics/ && \
    cp Spacefox-47.05a/raw/onLoad_gfx_Spacefox.init df_linux/raw/ && \
    rm -r Spacefox-47.05a

# Game settings.
ARG PLAY_INTRO=NO
ARG SHOW_FPS=NO
RUN sed -e "s/WINDOWED:YES/WINDOWED:NO/" \
    -e "s/SOUND:YES/SOUND:NO/" \
    -e "s/INTRO:YES/INTRO:${PLAY_INTRO}/" \
    -e "s/FPS:NO/FPS:${SHOW_FPS}/" \
    -i df_linux/data/init/init.txt
RUN sed -e "s/AUTOSAVE:NONE/AUTOSAVE:SEASONAL/" \
    -e "s/SHOW_FLOW_AMOUNTS:NO/SHOW_FLOW_AMOUNTS:YES/" \
    -i df_linux/data/init/d_init.txt