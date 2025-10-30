ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-python:3.11-alpine3.19
FROM ${BUILD_FROM}

# Install dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    pulseaudio-utils \
    alsa-utils \
    jq \
    bash

# Install Wyoming Satellite
RUN pip3 install --no-cache-dir --break-system-packages \
    wyoming-satellite

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
