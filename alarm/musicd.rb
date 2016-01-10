#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

# add Load Path
$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/common')
$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/musicd')

require 'thread'
require 'context'
require 'musicd-worker'
require 'dbus-server'

RPiClock::Context::load_conf ARGV[0]

conf = RPiClock::Context::conf
RPiClock::Context::set_logger conf['log']['output'], conf['log']['level']

# create message queue
msgQueue = Queue.new

# create D-Bus thread
dbusThread = Thread.new (msgQueue) do |queue|
  dbusServer = RPiClock::DbusServer.new queue
  dbusServer.start
end

# infinite loop
RPiClock::MusicdWorker.new(msgQueue).start
