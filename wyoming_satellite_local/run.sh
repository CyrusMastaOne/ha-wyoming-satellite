#!/usr/bin/with-contenv bashio

set -e

# Read config
NAME=$(bashio::config 'name')
URI=$(bashio::config 'uri')
MIC_DEVICE=$(bashio::config 'mic_device')
SND_DEVICE=$(bashio::config 'snd_device')
WAKE_URI=$(bashio::config 'wake_uri')
WAKE_WORD=$(bashio::config 'wake_word')
DEBUG=$(bashio::config 'debug')

# Set PulseAudio server
export PULSE_SERVER=unix:/run/audio/pulse/native

bashio::log.info "Starting Wyoming Satellite: ${NAME}"
bashio::log.info "URI: ${URI}"
bashio::log.info "Microphone: ${MIC_DEVICE}"
bashio::log.info "Speaker: ${SND_DEVICE}"

# Wait for PulseAudio
bashio::log.info "Waiting for PulseAudio socket..."
for i in {1..30}; do
    if [ -S /run/audio/pulse/native ]; then
        bashio::log.info "PulseAudio socket found"
        break
    fi
    if [ $i -eq 30 ]; then
        bashio::log.error "PulseAudio socket not found after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Test PulseAudio connection
bashio::log.info "Testing PulseAudio connection..."
if ! pactl info > /dev/null 2>&1; then
    bashio::log.error "Cannot connect to PulseAudio"
    pactl info || true
    exit 1
fi

# Set default sink
bashio::log.info "Setting default sink to ${SND_DEVICE}..."
if ! pactl set-default-sink "${SND_DEVICE}"; then
    bashio::log.warning "Could not set default sink, continuing anyway..."
fi

# Unmute and set volume
bashio::log.info "Unmuting and setting volume..."
pactl set-sink-mute "${SND_DEVICE}" 0 || true
pactl set-sink-volume "${SND_DEVICE}" 80% || true

# List audio devices for debugging
if [ "${DEBUG}" = "true" ]; then
    bashio::log.info "Available sinks:"
    pactl list sinks short
    bashio::log.info "Available sources:"
    pactl list sources short
fi

# Build Wyoming Satellite command
CMD="python3 -m wyoming_satellite"
CMD="${CMD} --name '${NAME}'"
CMD="${CMD} --uri '${URI}'"
CMD="${CMD} --mic-command 'parecord --device=${MIC_DEVICE} --rate=%s --channels=%s --format=s%sle --raw'"
CMD="${CMD} --snd-command 'paplay --device=${SND_DEVICE} --rate=%s --channels=%s --format=s%sle --raw'"

# Add wake word if configured
if [ -n "${WAKE_URI}" ] && [ -n "${WAKE_WORD}" ]; then
    bashio::log.info "Wake word enabled: ${WAKE_WORD}"
    CMD="${CMD} --wake-uri '${WAKE_URI}'"
    CMD="${CMD} --wake-word-name '${WAKE_WORD}'"
fi

# Add debug flag
if [ "${DEBUG}" = "true" ]; then
    CMD="${CMD} --debug"
fi

# Test speaker with a beep
bashio::log.info "Testing speaker output..."
if ! timeout 5 paplay --device="${SND_DEVICE}" --channels=1 --rate=16000 --format=s16le < /dev/urandom 2>&1 | head -c 8192 > /dev/null; then
    bashio::log.warning "Speaker test failed, but continuing..."
fi

# Start Wyoming Satellite
bashio::log.info "Starting Wyoming Satellite..."
bashio::log.info "Command: ${CMD}"

eval "${CMD}"
