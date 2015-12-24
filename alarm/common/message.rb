# RPiClock/alarmd/message.rb
#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

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
