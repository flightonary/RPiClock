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
$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/alarmd')

require 'thread'
require 'context'
require 'alarmd-worker'
require 'timer'
require 'message'

RPiClock::Context::load_conf ARGV[0]

conf = RPiClock::Context::conf
RPiClock::Context::set_logger conf['log']['output'], conf['log']['level']

# create message queue
msgQueue = Queue.new

# create timer thread
timer_sec = conf['alarm']['check_period']
timerThread = Thread.new do
  alarmdTimer = RPiClock::Timer.new msgQueue, align_with_clock=true
  alarmdTimer.start_repeatedly timer_sec, RPiClock::Message.new(:timeout)
end

# infinite loop
RPiClock::AlarmdWorker.new(msgQueue).start
