# RPiClock/alarmd/message.rb
#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#

module RPiClock
  class Message < Hash
    def initialize type
      super
      self[:type] = type
    end

    def type
      self[:type]
    end
  end
end
