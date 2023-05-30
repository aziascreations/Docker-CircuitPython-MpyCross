# -===- Compiling stage -===-
# Preparing the temporary compiler container
FROM alpine:latest AS build

# Using the given release tag or 8.1.0 instead.
ARG CIRCUITPYTHON_GIT_TAG=8.1.0

# Going into `/build` and working from there.
WORKDIR /build

# Installing requirements
# The 3 `apk add` commands accomplish the following things:
#  1. Replacements for Alpine's missing `build-essential` package
#  2. Requirements for `make fetch-submodules`
#  3. Requirements for `pip3 install -r requirements-dev.txt`
RUN apk update && \
    apk add --no-cache alpine-sdk autoconf automake bash bind-tools bison coreutils file findutils gettext gettext-dev gperf jq rsync texinfo wget xz && \
    apk add --no-cache bash git make gettext uncrustify cmake && \
    apk add --no-cache python3 py3-pip rust cargo

# Cloning & compiling mpy-cross
# These are all grouped in one step since `make fetch-submodules` can and WILL fail silently when it cannot fetch some
#  dependencies which in turn will prevent `make -C mpy-cross` from completing.
# Don't ask why, I don't know, just be glad you aren't the one who lost hours to this because of a shody internet connection.
RUN git clone --depth 1 --branch $CIRCUITPYTHON_GIT_TAG https://github.com/adafruit/circuitpython.git && \
    cd /build/circuitpython && \
    make fetch-submodules && \
    pip3 install -r requirements-dev.txt && \
    make -C mpy-cross

# -===- Final stage -===-
# Preparing the final container
FROM alpine:latest AS final

# Setting up the labels
ARG CIRCUITPYTHON_GIT_TAG=8.1.0
LABEL org.opencontainers.image.authors="Herwin Bozet <herwin.bozet@gmail.com>"
LABEL org.opencontainers.image.description="Containerized version of mpy-cross that automatically compiles files when started."
LABEL org.opencontainers.image.url="https://github.com/aziascreations/Docker-CircuitPython-MpyCross"
LABEL org.opencontainers.image.version=$CIRCUITPYTHON_GIT_TAG
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="mpy-cross-cpy"
LABEL maintainer="Herwin Bozet <herwin.bozet@gmail.com>"

# Copying compiled executables from the previous container.
COPY --from="build" /build/circuitpython/mpy-cross/mpy-cross /usr/bin/

# Adding the `entrypoint.sh` file and setting its permissions.
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 555 /entrypoint.sh
ENTRYPOINT /entrypoint.sh
