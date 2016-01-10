#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'http-get'
require 'json'

module RPiClock
  class AlarmCheck
    include Context

    def initialize
      @alarms = JSON.parse('[]')
      @holidayCheck = HolidayCheck.new
    end

    def sync
      http_req = HttpGet.new conf['alarm']['location']
      http_req.onSuccess { |response|
        json = response.body
        @alarms = JSON.parse(json)
        logger.debug('get alarm list : ' + json)
      }.onFailure { |response|
        logger.warn('can not get alarm list : ' + response.value)
      }.do
    end

    def tobeAlarmList
      time = Time.now.strftime('%H:%M')
      week = Time.now.strftime('%a').downcase
      @alarms.select { |a|
        a['enabled'] && a['time'] == time && a['repeat'].include?(week) &&
        ( a['holiday_off'] == false || @holidayCheck.holiday? == false )
      }
    end
  end

  class HolidayCheck
    include Context

    def initialize
      @todayIsHoliday = nil
      @lastUpdate = ''
    end

    def holiday?
      update if @todayIsHoliday.nil? || date != @lastUpdate
      if @todayIsHoliday.nil?
        false
      else
        @todayIsHoliday
      end
    end

    def update
      http_req = HttpGet.new conf['holiday']['location']
      http_req.onSuccess { |response|
        flag = response.body
        @lastUpdate = date
        @todayIsHoliday =
          if conf['holiday']['case_of_true'].include? flag
            true
          elsif conf['holiday']['case_of_false'].include? flag
            false
          else
            nil
          end
        logger.debug('holiday update. today is holiday? => ' + @todayIsHoliday.to_s)
      }.onFailure { |response|
        logger.warn('can not get holiday flag : ' + response.value)
      }.do
    end

    private
    def date
      Time.now.strftime('%F')
    end
  end
end
