#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'message'
require 'context'
require 'alarm-db'

module RPiClock
  class AlarmdWorker
    include Context

    def initialize queue
      @queue = queue
      @alarmCheck = AlarmCheck.new
    end

    def start
      while true
        msg = @queue.pop

        case msg.type
        when :timeout
          logger.debug("alarm check timer timeout")
          @alarmCheck.read
          if @alarmCheck.needToAlarm?
            logger.debug("alarm on !!")
          end
        else
          logger.warn("undefined message")
        end
      end
    end

  end
end
