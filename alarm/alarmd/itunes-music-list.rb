#
# This file is part of the RPiClock project
# Copyright (C) 2013 tonary
#

require 'http-get'
require 'rexml/document'

module RPiClock
  module ITunesMusicList
    extend self

    def trackUrlListFromSongs rssURL
      trackUrlList = Array.new
      http_req = HttpGet.new rssURL
      http_req.onSuccess { |response|
        doc = REXML::Document.new(response.body)
        doc.elements.each("/feed/entry/link[@assetType='preview']") { |e|
          trackUrlList << e.attributes['href']
        }
      }.onFailure { |response|
        logger.warn('can not http get : ' + response.value)
      }.do
      return trackUrlList
    end
  end
end
