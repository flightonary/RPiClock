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
    # mplayer -ao pulse:172.17.0.6 TomCat.wav
    MPLAYER  = "mplayer -slave -idle -quiet -softvol"

    def initialize
      start()
    end

    def play_file (path)
      write_cmd("loadfile #{path}")
    end

    def play_list (path)
      write_cmd("loadlist #{path}")
    end

    def stop
      write_cmd('stop')
    end

    def volume (vol)
      return if vol < 0 or 100 < vol
      write_cmd("volume #{vol}")
    end

    def get_time_length
      write_cmd('get_time_length')
      response = wait_for_output('ANS_LENGTH')
      return response == nil ? nil : response.split['='][1].to_f
    end

    def restart
      kill()
      start()
    end

    protected
    def start
      @pipe = IO.popen(MPLAYER.split(" "), "r+")
      @queueOfPipeOut = Queue.new

      # observe outputs
      @readThread = Thread.new {
        while @pipe.closed? == false
          line = @pipe.gets.chomp
          @queueOfPipeOut.push line
        end
      }
    end

    def kill
      write_cmd('quit')
      @readThread.kill
      @pipe = nil
    end

    def write_cmd (string)
      return if @pipe == nil
      @pipe.puts(string)
    end

    def wait_for_response (key)
      # timeout thread
      timeoutId = rand.to_s
      th = Thread.new (timeoutId) { |timeoutId|
        sleep(1)
        @queueOfPipeOut.push(timeoutId)
      }
      while true
        line = @queueOfPipeOut.pop
        if line == timeoutId
          STDERR.puts("[#{__FILE__}]waitParam: timeout")
          return nil
        else
          return line if line.include?(key)
        end
      end
    end
  end
end
