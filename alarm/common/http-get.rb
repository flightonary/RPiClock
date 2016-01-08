#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

require 'net/http'
require 'uri'
require 'json'

module RPiClock
  class HttpGet
    def initialize location
      @location  = location
      @onSuccess = Proc.new {|response|}
      @onFailure = Proc.new {|response|}
    end

    def onSuccess (&block)
      @onSuccess = block
      self
    end

    def onFailure (&block)
      @onFailure = block
      self
    end

    def do
      uri = URI.parse(@location)
      request = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        request.use_ssl = true
        request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      begin
        response = request.start do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          http.get(uri.request_uri)
        end
        case response
        when Net::HTTPSuccess
          @onSuccess.call response
        else
          @onFailure.call response
        end
      rescue => e
        p e
      end
    end
  end
end
