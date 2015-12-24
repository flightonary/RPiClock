#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'fileutils'
require 'net/http'
require 'uri'
require 'yaml'
require 'rexml/document'
require 'thread'

module RPiClock
  class MPlayer
    MPLAYER  = "mplayer -slave -quiet -softvol -nocache -nolirc -idle"
    PARAMS = ['ANS_LENGTH=']

    def initialize
      start()
    end

    def play (path)
      stop()
      initParams()
      write_cmd("loadfile #{path}")
      write_cmd('get_time_length')
      waitParam(PARAMS[0])
    end

    def stop
      write_cmd('stop')
    end

    def volume (vol)
      return if vol < 0 or 100 < vol
      write_cmd("volume #{vol}")
    end

    def get_time_length
      return @params[PARAMS[0]].to_f
    end

    def restart
      kill()
      start()
    end

    protected
    def start
      @pipe = IO.popen(MPLAYER.split(" "), "r+")
      @queue = Queue.new

      # observe params
      initParams()
      @readThread = Thread.new {
        while @pipe.closed? == false
          line = @pipe.gets.chomp
          PARAMS.each { |key|
            @queue.push({key=>line.gsub(/#{key}/, '')}) if line.include?(key)
          }
        end
      }
    end

    def kill
      write_cmd('quit')
      @readThread.kill
      @pipe = nil
    end

    def initParams
      @queue.clear
      @params = Hash.new
    end

    def waitParam (key)
      # timeout thread
      reqId = rand
      th = Thread.new (reqId) { |reqId|
        sleep(1)
        @queue.push({'reqId'=>reqId})
      }
      while true
        msg = @queue.pop
        if msg['reqId'] == reqId
          # timeout !!
          STDERR.puts("[#{__FILE__}]waitParam: timeout")
          return
        else
          @params.merge! msg
          if msg[key] != nil
            # get required param
            th.kill
            return
          end
        end
      end
    end

    def write_cmd (string)
      return if @pipe == nil
      @pipe.puts(string)
    end
  end
end
