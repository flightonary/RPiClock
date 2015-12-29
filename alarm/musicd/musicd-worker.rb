#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'context'
require 'message'
require 'mplayer'
require 'itunes-music-list'

module RPiClock
  class MusicdWorker
    include Context

    def initialize queue
      @queue = queue
      @mPlayer = MPlayer.new
      # @musicList = ITunesMusicList.new
      # @timerThread = Thread.new {}
      # @requestNumber = 0
    end

    def start
      logger.info("[musicd] musicd-worker started")
      while true
        msg = @queue.pop

        case msg[:type]
        when :dbus
          case msg[:player_action]
          when :play_file
            logger.debug("[musicd] play_file path:#{msg[:path]}")
            @mPlayer.play_file(msg[:path])
          when :play_itunes_rss_preview
            logger.info("[musicd] Not impl. play_itunes_rss_preview")
            # @musicList.createMusicList(msg[:rss], msg[:lookup])
            # playNextMusic()
            # loopTimer()
          when :stop
            # nextRequestNumber()
            # @timerThread.kill
            @mPlayer.stop
          else
            logger.error("[musicd] undefined interface")
          end

        # when :loop_timer_timeout
        #   if msg[:requestNumber] == @requestNumber
        #     playNextMusic()
        #     loopTimer()
        #   end
        else
          logger.error("[musicd] undefined message type")
        end
      end
    end

    # def playNextMusic
    #   url = @musicList.getNextMusicURL
    #   @mPlayer.play(url)
    # end
    #
    # def loopTimer
    #   @timerThread.kill
    #   time = @mPlayer.get_time_length
    #   @timerThread = Thread.new(time, @requestNumber, @queue) do |time, reqNum, queue|
    #     sleep time
    #     msg = Message.new :loop_timer_timeout
    #     msg[:requestNumber] = reqNum
    #     queue.push(msg)
    #   end
    # end
    #
    # def nextRequestNumber
    #   if @requestNumber == 9999
    #     @requestNumber = 0
    #   else
    #     @requestNumber += 1
    #   end
    # end
  end
end
