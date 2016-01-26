#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#

module RPiClock
  class Timer
    def initialize queue, align_with_clock=false
      @queue = queue
      @align_with_clock = align_with_clock
    end

    def start_repeatedly sec, timeout_msg
      while true
        sleep Timer.rest_of_time(sec, @align_with_clock)
        @queue.push timeout_msg
      end
    end

    def self.rest_of_time sec, align_with_clock
      # align with zero second in time
      if align_with_clock
        sec - (Time.now.sec % sec)
      else
        sec
      end
    end
  end
end
