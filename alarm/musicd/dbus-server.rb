#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#

require 'dbus'
require 'message'
require 'context'

module RPiClock
  class DBusObject < DBus::Object
    include Context

    def initialize objectName, queue
      super objectName
      @queue = queue
    end

    dbus_interface "io.docker.container.musicd" do
      dbus_method :play_file, "in path:s" do |path|
        msg = Message.new :dbus
        msg[:player_action] = :play_file
        msg[:path] = path
        @queue.push msg
      end

      dbus_method :play_list, "in list:s" do |list|
        msg = Message.new :dbus
        msg[:player_action] = :play_list
        msg[:list] = list
        @queue.push msg
      end

      dbus_method :stop, "" do
        msg = Message.new :dbus
        msg[:player_action] = :stop
        @queue.push msg
      end

      dbus_method :echo, "in voice:s, out ret:s" do |voice|
        [voice]
      end
    end
  end

  class DbusServer
    def initialize queue
      @queue = queue
    end

    def start
      bus = DBus.system_bus
      service = bus.request_service("io.docker.container")

      containerId = `hostname`.chop
      obj = DBusObject.new("/io/docker/container/#{containerId}", @queue)
      service.export(obj)

      begin
        main = DBus::Main.new
        main << bus
        main.run
      rescue DBus::Error => e
        logger.fatal(e)
        exit 1
      end
    end
  end
end
