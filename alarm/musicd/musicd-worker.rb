#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'json'
require 'tempfile'
require 'context'
require 'message'
require 'mplayer'
require 'music-cache'

module RPiClock
  class MusicdWorker
    include Context

    def initialize queue
      @queue = queue
      @mPlayer = MPlayer.new
      @mCache = MusicCache.new conf['cache']['directory'], conf['cache']['age']
    end

    def start
      logger.info("[musicd] musicd-worker started")
      while true
        msg = @queue.pop

        case msg[:type]
        when :dbus
          case msg[:player_action]
          when :play_file
            @mPlayer.play_file(msg[:path])
          when :play_list
            @mCache.cleanup
            playList = JSON.parse msg[:list]
            cacheList = @mCache.cached_list playList
            tmpfile = to_tmp_file(cacheList)
            @mPlayer.play_list(tmpfile.path)
          when :stop
            @mPlayer.stop
          else
            logger.error("[musicd] undefined action")
          end
        else
          logger.error("[musicd] undefined message type")
        end
      end
    end

    def to_tmp_file list
      tmpfile = Tempfile.new('list')
      tmpfile.puts list
      tmpfile.close
      return tmpfile
    end
  end
end
