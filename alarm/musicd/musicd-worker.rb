#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'player'
require 'message'

module RPiClock
  class MusicdWorker
    include Context

    def initialize queue
      @queue = queue
      @mPlayer = MPlayer.new
      @musicList = ITunesMusicList.new
      @timerThread = Thread.new {}
      @requestNumber = 0
    end

    def start
      while true
        msg = @queue.pop

        case msg[:type]
        when :dbus
          case msg[:player_action]
          when :start
            @musicList.createMusicList(msg[:rss], msg[:lookup])
            playNextMusic()
            loopTimer()
          when :stop
            nextRequestNumber()
            @timerThread.kill
            @mPlayer.stop
          else
            logger.error("[musicd error]: undefined interface")
          end

        when :loop_timer_timeout
          if msg[:requestNumber] == @requestNumber
            playNextMusic()
            loopTimer()
          end
        else
          logger.error("[musicd error]: undefined message type")
        end
      end
    end

    def playNextMusic
      url = @musicList.getNextMusicURL
      @mPlayer.play(url)
    end

    def loopTimer
      @timerThread.kill
      time = @mPlayer.get_time_length
      @timerThread = Thread.new(time, @requestNumber, @queue) do |time, reqNum, queue|
        sleep time
        msg = Message.new :loop_timer_timeout
        msg[:requestNumber] = reqNum
        queue.push(msg)
      end
    end

    def nextRequestNumber
      if @requestNumber == 9999
        @requestNumber = 0
      else
        @requestNumber += 1
      end
    end
  end
end
