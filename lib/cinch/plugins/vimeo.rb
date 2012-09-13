# coding: utf-8

require_relative '../helpers/is_channel_disabled'
require 'httparty'

module Cinch
  module Plugins
    class Vimeo
      include Cinch::Plugin

      # From Google's Closure Library, with slight modifications:
      # http://closure-library.googlecode.com/svn/docs/closure_goog_ui_media_VIMEO.js.source.html
      VIMEO_VIDEO_REGEXP = /https?:\/\/(?:[a-zA-Z]{2,3}\.)?(?:vimeo\.com\/)(\d+)/i
      VIMEO_API_VIDEO_URL = "http://vimeo.com/api/v2/video/%s.json"

      listen_to :channel, method: :listen_to_channel
      def listen_to_channel(m)
        return if is_channel_disabled?(m.channel)
        return unless m.message.match(VIMEO_VIDEO_REGEXP)
        videos = m.message.scan(VIMEO_VIDEO_REGEXP).flatten.reject(&:'nil?').uniq

        videos.each {|v|
          response = HTTParty.get(VIMEO_API_VIDEO_URL % v, headers: {'User-Agent' => "HTTParty/#{HTTParty::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"})
          #raise StandardError, '%s - %s (%d)' % [response['error']['message'], v, response['error']['code']] if response['error']
          video = response[0]
          m.reply "Vimeo » #{Format(:bold,'%<title>s')} (%<length>s) · by %<uploader>s on %<uploaded>s · #{Format(:green,'☝')}%<likes>s · %<views>s views" % {
            title: video['title'],
            uploader: video['user_name'],
            uploaded: Time.parse(video['upload_date']).strftime('%F'),
            length: seconds_to_time(video['duration'].to_i),
            likes: commify_numbers(video['stats_number_of_likes'].to_i),
            views: commify_numbers(video['stats_number_of_plays'].to_i)
          }
        }
      #rescue => e
        #m.reply "Vimeo » #{e.message}"
      end

      private

      def seconds_to_time(seconds, div=2)
        parts = [60,60][-div+1..-1] # d h (m)
        ['%02d'] * div * ':' %
          # the .reverse lets us put the larger units first for readability
          parts.reverse.inject([seconds]) {|result, unitsize|
            result[0,0] = result.shift.divmod(unitsize)
            result
          }
      end

      def commify_numbers(n)
        sign, real, decimal = n.to_s.match(/(\+|-)*(\d+)(.\d+)*/).to_a[1..-1]
        [sign, real.reverse.scan(/\d{1,3}/).join(',').reverse, decimal].join
      end

    end
  end
end