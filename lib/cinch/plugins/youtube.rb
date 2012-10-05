# coding: utf-8

require_relative '../helpers/is_channel_disabled'
require 'httparty'

module Cinch
  module Plugins
    class YouTube
      include Cinch::Plugin

      # From Google's Closure Library, with slight modifications:
      # http://closure-library.googlecode.com/svn/docs/closure_goog_ui_media_youtube.js.source.html
      YOUTUBE_VIDEO_REGEXP = /https?:\/\/(?:[a-zA-Z]{2,3}\.)?(?:youtube\.com\/watch)(?:\?(?:[\w=-]+&(?:amp;)?)*v=([\w-]+)(?:&(?:amp;)?[\w=-]+)*)?(?:#[!]?(?:(?:(?:[\w=-]+&(?:amp;)?)*(?:v=([\w-]+))(?:&(?:amp;)?[\w=-]+)*)|(?:[\w=&-]+)))?[^\w-]?|http:\/\/(?:[a-zA-Z]{2,3}\.)?(?:youtu\.be\/)([\w-]+)/i
      YOUTUBE_API_VIDEO_URL = "http://gdata.youtube.com/feeds/api/videos/%s?v=2&alt=jsonc"

      listen_to :channel, method: :listen_to_channel
      def listen_to_channel(m)
        return if is_channel_disabled?(m.channel)
        return unless m.message.match(YOUTUBE_VIDEO_REGEXP)
        videos = m.message.scan(YOUTUBE_VIDEO_REGEXP).flatten.reject(&:'nil?').uniq

        videos.each {|v|
          response = HTTParty.get(YOUTUBE_API_VIDEO_URL % v, headers: {'User-Agent' => "HTTParty/#{HTTParty::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"})
          raise StandardError, '%s - %s (%d)' % [response['error']['message'], v, response['error']['code']] if response['error']
          video = response['data']
          m.reply "YouTube » #{Format(:bold,'%<title>s')} (%<length>s) · by %<uploader>s on %<uploaded>s · #{Format(:green,'☝')}%<likes>s #{Format(:red,'☟')}%<dislikes>s · %<views>s views" % {
            title: video['title'],
            uploader: video['uploader'],
            uploaded: Time.parse(video['uploaded']).strftime('%F'),
            length: seconds_to_time(video['duration']),
            likes: commify_numbers(video['likeCount'].to_i),
            dislikes: commify_numbers(video['ratingCount'].to_i - video['likeCount'].to_i),
            views: commify_numbers(video['viewCount'].to_i)
          }
        }
      rescue => e
        m.reply "YouTube » #{e.message}"
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