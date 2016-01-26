# RPiClock

Alarm clock on Raspberry Pi

## Overview
**RPiClock** is a system for alarm clock service on Raspberry Pi. RPiClock provides a way setting alarms via web browser and play preview songs fetched from iTunes as alarm music.

## Required Systems and Services
### Hardware
- Raspberry Pi Model B, or later.
- Plugable USB audio adapter (chip: C-Media HS-100B) or something equivalent

### Software
- Arch Linux
- docker
- docker-compose (https://gist.github.com/jkawamoto/6bd4837db31b6e80c424)

## Usage
### systemd units
/etc/systemd/system/rpiclock-web.service

    [Unit]
    Description=RPiClock web server daemon
    Requires=docker.service
    After=docker.service

    [Service]
    Restart=always
    ExecStart=/usr/local/bin/docker-compose -f docker-compose.yml -f production.yml up web
    ExecStop=/usr/local/bin/docker-compose stop web
    WorkingDirectory=/home/alarm/RPiClock

    [Install]
    WantedBy=multi-user.target

/etc/systemd/system/rpiclock-alarm.service

    [Unit]
    Description=RPiClock alarm server daemon
    Requires=docker.service
    After=docker.service

    [Service]
    Restart=always
    ExecStart=/usr/local/bin/docker-compose -f docker-compose.yml -f production.yml up alarm
    ExecStop=/usr/local/bin/docker-compose stop alarm
    WorkingDirectory=/home/alarm/RPiClock

    [Install]
    WantedBy=multi-user.target

/etc/systemd/system/rpiclock-pulseaudio.service

    [Unit]
    Description=RPiClock pulseaudio server daemon
    Requires=docker.service
    After=docker.service

    [Service]
    Restart=always
    ExecStart=/usr/local/bin/docker-compose up pulseaudio
    ExecStop=/usr/local/bin/docker-compose stop pulseaudio
    WorkingDirectory=/home/alarm/RPiClock/subsystem

    [Install]
    WantedBy=multi-user.target

### launch
Open http://(YOUR-RPI-HOST):3000 after RPiClock launched.

    # pwd
    /home/alarm
    # git clone https://github.com/flightonary/RPiClock.git
    # systemctl enable rpiclock-web
    # systemctl enable rpiclock-alarm
    # systemctl enable rpiclock-pulseaudio
    # systemctl start rpiclock-web
    # systemctl start rpiclock-alarm
    # systemctl start rpiclock-pulseaudio

## Contributor
tonary (jetbeaver@gmail.com)
