#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'dbus'
require 'json'
require 'message'
require 'context'
require 'alarm-db'
require 'itunes-music-list'

module RPiClock
  class AlarmdWorker
    include Context

    def initialize queue
      @queue = queue
      @alarmCheck = AlarmCheck.new
      @musicd_iface = get_musicd_interface
    end

    def start
      logger.info("[alarmd] alarmd-worker started")
      while true
        msg = @queue.pop

        case msg.type
        when :timeout
          logger.debug("[alarmd] alarm check timer timeout")
          do_alarm
        else
          logger.warn("[alarmd] undefined message")
        end
      end
    end

    def do_alarm
      @alarmCheck.sync
      tobeAlarms = @alarmCheck.tobeAlarmList
      if not tobeAlarms.empty?
        logger.info("[alarmd] alarm on")
        if tobeAlarms[0]['sound'].downcase == 'tomcat'
          @musicd_iface.play_file('TomCat.wav')
        else
          rssUrl = conf['itunes']['rss']['topsongs']
          trackUrlList = ITunesMusicList.trackUrlListFromSongs rssUrl
          @musicd_iface.play_list(JSON.generate(trackUrlList))
        end
      end
    end

    protected
    def get_musicd_interface
      bus = DBus::SystemBus.instance
      service = bus.service("io.docker.container")
      containerId = `hostname`.chop
      object = service.object("/io/docker/container/#{containerId}")
      object.introspect
      object.default_iface = "io.docker.container.musicd"
      return object
    end
  end
end
