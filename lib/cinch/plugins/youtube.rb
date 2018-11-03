# coding: utf-8

require_relative '../helpers/is_channel_disabled'
require 'httparty'
require 'iso8601'

module Cinch
  module Plugins
    class YouTube
      include Cinch::Plugin
      set(
        required_options: [:api_key])

      # From Google's Closure Library, with slight modifications:
      # http://closure-library.googlecode.com/svn/docs/closure_goog_ui_media_youtube.js.source.html
      YOUTUBE_VIDEO_REGEXP = /https?:\/\/(?:[a-zA-Z]{2,3}\.)?(?:m\.)?(?:youtube\.com\/watch)(?:\?(?:[\w=-]+&(?:amp;)?)*v=([\w-]+)(?:&(?:amp;)?[\w=-]+)*)?(?:#[!]?(?:(?:(?:[\w=-]+&(?:amp;)?)*(?:v=([\w-]+))(?:&(?:amp;)?[\w=-]+)*)|(?:[\w=&-]+)))?[^\w-]?|https?:\/\/(?:[a-zA-Z]{2,3}\.)?(?:youtu\.be\/)([\w-]+)/i
      YOUTUBE_API_VIDEO_URL = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=%s&key=%s"

      listen_to :channel, method: :listen_to_channel
      def listen_to_channel(m)
        return if is_channel_disabled?(m.channel)
        return unless m.message.match(YOUTUBE_VIDEO_REGEXP)
        video_ids = m.message.scan(YOUTUBE_VIDEO_REGEXP).flatten.reject(&:'nil?').uniq
        response = HTTParty.get(YOUTUBE_API_VIDEO_URL % [video_ids.join(','), config[:api_key]], headers: {'User-Agent' => "HTTParty/#{HTTParty::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"})
        raise StandardError, '%s - %s (%d)' % [response['error']['message'], video_ids.join(', '), response['error']['code']] if response['error']
        videos = response['items']

        videos.each {|video|
          m.reply "#{Format(:bold,'YouTube »')} #{Format(:purple,'%<title>s')} (%<length>s) · by %<uploader>s on %<uploaded>s · #{Format(:green,'⬆︎%<likes>s')} #{Format(:red,'⬇︎%<dislikes>s')} · %<views>s views" % {
            title: video['snippet']['title'],
            uploader: video['snippet']['channelTitle'],
            uploaded: Time.parse(video['snippet']['publishedAt']).strftime('%F'),
            length: seconds_to_time(ISO8601::Duration.new(video['contentDetails']['duration']).to_seconds),
            likes: commify_numbers(video['statistics']['likeCount'].to_i),
            dislikes: commify_numbers(video['statistics']['dislikeCount'].to_i),
            views: commify_numbers(video['statistics']['viewCount'].to_i)
          }
        }
      rescue => e
        m.reply "#{Format(:bold,'YouTube »')} #{e.message}"
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
