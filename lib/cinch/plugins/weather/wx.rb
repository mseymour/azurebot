require 'httparty'
require 'hashie'

module Cinch
  module Plugins
    class Weather
      class Wx
        include HTTParty
        base_uri 'api.wunderground.com/api'
        format :json

        attr_accessor :type
        attr_reader :apikey

        def initialize(apikey, type=:metric)
          @type, @apikey = type,apikey
        end

        def get(query, *features)
          features << :conditions if features.empty?
          Hashie::Mash.new(self.class.get("/#{@apikey}/#{features * "/"}/q/#{query}.json"))
        end
      end
    end
  end
end