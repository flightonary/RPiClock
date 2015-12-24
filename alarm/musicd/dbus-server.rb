#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'rubygems'
require 'dbus'
require 'message'

module RPiClock
  class DBusInterface < DBus::Object
    def initialize objectName, queue
      super objectName
      @queue = queue
    end

    dbus_interface "app.RPiClock.Musicd" do
      dbus_method :start, "in rss:s, in lookup:s" do |rss, lookup|
        msg = Message.new :dbus
        msg[:player_action] = :start
        msg[:rss] = rss
        msg[:lookup] = lookup
        @queue.push msg
      end
    end

    dbus_interface "app.RPiClock.Musicd" do
      dbus_method :stop, "" do
        msg = Message.new :dbus
        msg[:player_action] = :stop
        @queue.push msg
      end
    end
  end

  class DbusServer
    def initialize queue
      @queue = queue
    end

    def start
      bus = DBus.system_bus
      service = bus.request_service("app.RPiClock.Musicd")

      obj = DBusInterface.new("/app/RPiClock/Musicd", @queue)
      service.export(obj)

      main = DBus::Main.new
      main << bus
      main.run
    end
  end
end
