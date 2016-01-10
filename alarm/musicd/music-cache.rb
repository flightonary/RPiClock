#
# This file is part of the RPiClock project
# Copyright (C) 2015 tonary
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'thread'
require 'fileutils'
require 'open-uri'
require 'context'

module RPiClock
  class MusicCache
    include Context

    def initialize cacheDir, expire
      FileUtils.mkdir_p cacheDir if not File.exist? cacheDir
      @cacheDir = cacheDir
      @expire = expire
    end

    def cached_list originalList
      threads = Array.new
      originalList.each do |url_t|
        threads << Thread.new(url_t) do |url|
          fileName = "#{@cacheDir}/#{File.basename(url)}"
          cacheName = fileName + ".mp3"

          if not File.exist? cacheName
            open(fileName, 'wb') do |output|
              open(url) do |data|
                output.write(data.read)
              end
            end
            `avconv -i #{fileName} #{cacheName}`
          end

          Thread.current[:output] = cacheName
        end
      end

      threads.map do |thread|
        thread.join
        thread[:output]
      end
    end

    def cleanup
      expDay = /(\d+)day/.match(@expire)[1]
      `find #{@cacheDir} -atime +#{expDay} -exec rm -f {} \;`
    end
  end
end
