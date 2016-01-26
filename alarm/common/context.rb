#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#

require 'yaml'
require 'logger'
require 'singleton'

module RPiClock
  class Config
    include Singleton

    def initialize
      @yaml = {}
    end

    def load path
      @yaml = YAML.load_file path
    end

    def yaml
      @yaml
    end
  end

  class Log
    include Singleton

    def initialize
      @logger = Logger.new STDOUT
      $stdout.sync = true
    end

    def setup out, level
      @logger = Logger.new out
      @logger.level = level
    end

    def logger
      @logger
    end
  end

  module Context
    extend self

    def load_conf path
      Config.instance.load path
    end

    def set_logger out, level
      out = eval(out) if ["STDOUT", "STDERR"].include? out
      level = Logger.module_eval(level)
      Log.instance.setup out, level
    end

    def conf
      Config.instance.yaml
    end

    def logger
      Log.instance.logger
    end
  end
end
