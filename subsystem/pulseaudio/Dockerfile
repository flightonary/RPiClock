# Docker base image
FROM resin/rpi-raspbian:jessie

RUN apt-get update -qq
RUN apt-get install -y pulseaudio pulseaudio-utils
RUN apt-get install -y alsa-utils
RUN apt-get clean

ENV HOSTOS_AUDIO_GID 92
RUN useradd -m pulseaudio
RUN groupadd -g $HOSTOS_AUDIO_GID host_audio
RUN usermod -aG audio,host_audio,pulse,pulse-access pulseaudio
USER pulseaudio
