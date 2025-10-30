ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install dependencies (python3 is already in base-python image)
RUN apk add --no-cache \
    pulseaudio \
    alsa-utils-libs \
    alsa-lib \
    jq \
    bash

# Install Wyoming Satellite
RUN pip3 install --no-cache-dir --break-system-packages \
    wyoming-satellite

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
