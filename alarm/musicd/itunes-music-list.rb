#
# This file is part of the RPiClock project
# Copyright (C) 2013 jetbeaver
#
# This is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License, version 2.1 as published by the Free Software Foundation.
# See the file "COPYING" for the exact licensing terms.

module RPiClock
  class ITunesMusicList
    class Mode
      Ascending = :ascending
      Random    = :random
    end

    def initialize
      @mode = Mode::Ascending
      @trackUrlList = nil
      @albumIdList = nil
      @rssURL = nil
      @lookupURL = nil
    end

    def createMusicList(rssURL, lookupURL, mode = Mode::Ascending)
      raise ArgumentError if mode != Mode::Ascending and mode != Mode::Random
      @rssURL = rssURL
      @lookupURL = lookupURL
      @albumIdList = getAlbumIdList(@rssURL)
      @trackUrlList = nil
    end

    def getNextMusicURL
      if @trackUrlList == nil or @trackUrlList.size == 0
        return nil if @albumIdList == nil or @albumIdList.size == 0
        @trackUrlList = getTrackUrlList(@albumIdList.shift, @lookupURL)
        if @mode == Mode::Ascending
          # track list is already in ascending order
        else # Mode::Random
          @trackUrlList.shuffle!
        end
      end

      return @trackUrlList.shift
    end

    protected
    def getBody (url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.start { |transaction|
        response = transaction.get(uri.request_uri)
        return response.body
      }
    end

    def getTrackUrlList (id, lookupURL)
      json = getBody(lookupURL + id.to_s)
      yaml = YAML.load(json)
      trackUrlList = Array.new
      yaml['results'].each do |track|
        next if track['wrapperType'] != 'track'
        trackUrlList << track['previewUrl']
      end
      return trackUrlList
    end

    def getAlbumIdList (rssURL)
      body = getBody(rssURL)
      doc = REXML::Document.new(body)

      albumList = Array.new
      doc.elements.each('/feed/entry/id') { |element|
        albumList << element.attributes['id']
      }
      return albumList
    end
  end
end
