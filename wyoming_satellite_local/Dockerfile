ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install only essential packages
# Note: parecord and paplay should be available via the audio: true mount
RUN apk add --no-cache \
    jq \
    bash

# Install Wyoming Satellite
RUN pip3 install --no-cache-dir --break-system-packages \
    wyoming-satellite

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
