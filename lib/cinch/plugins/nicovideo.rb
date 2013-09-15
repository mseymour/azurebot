# coding: utf-8

require_relative '../helpers/is_channel_disabled'
require 'httparty'

module Cinch
  module Plugins
    class NicoVideo
      include Cinch::Plugin

      # From Google's Closure Library, with slight modifications:
      # http://closure-library.googlecode.com/svn/docs/closure_goog_ui_media_youtube.js.source.html
      NICONICO_VIDEO_REGEXP = /https?:\/\/(?:[a-zA-Z]{2,3}\.)?(?:nicovideo\.jp\/watch\/)(sm\d+)/i
      NICONICO_API_VIDEO_URL = "http://ext.nicovideo.jp/api/getthumbinfo/%s"

      listen_to :channel, method: :listen_to_channel
      def listen_to_channel(m)
        return if is_channel_disabled?(m.channel)
        return unless m.message.match(NICONICO_VIDEO_REGEXP)
        videos = m.message.scan(NICONICO_VIDEO_REGEXP).flatten.reject(&:'nil?').uniq

        videos.each {|v|
          response = HTTParty.get(NICONICO_API_VIDEO_URL % v, headers: {'User-Agent' => "HTTParty/#{HTTParty::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"})["nicovideo_thumb_response"]
          raise StandardError, 'Video %s - %s' % [response['error']['description'], v] if response['status'].eql?('fail')
          video = response['thumb']
          m.reply "#{Format(:bold,'NicoNico »')} #{Format(:purple,'%<title>s')} (%<length>s) · uploaded %<uploaded>s · #{Format(:green,'%<likes>s mylists')} · %<views>s views" % {
            title: video['title'],
            uploaded: Time.parse(video['first_retrieve']).strftime('%F'),
            length: video['length'],
            likes: commify_numbers(video['mylist_counter'].to_i),
            views: commify_numbers(video['view_counter'].to_i)
          }
        }
      rescue => e
        m.reply "#{Format(:bold,'NicoNico »')} #{e.message}"
      end

      private

      def commify_numbers(n)
        sign, real, decimal = n.to_s.match(/(\+|-)*(\d+)(.\d+)*/).to_a[1..-1]
        [sign, real.reverse.scan(/\d{1,3}/).join(',').reverse, decimal].join
      end

    end
  end
end