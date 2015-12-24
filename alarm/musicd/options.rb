#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'optparse'
require 'ostruct'

class Options
  def self.parse(args)
    options = OpenStruct.new
    # default params
    options.conf_file = "../config/musicd.yml"

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: musicd.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      # Mandatory argument.
      opts.on("-c", "--config YAML",
              "Musicd configuration YAML file") do |conf_file|
        options.conf_file = conf_file
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end
