# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

module Cinch
  module Plugins
    class UrbanDictionary
      include Cinch::Plugin
      set plugin_name: "Urban Dictionary", help: "Gets the first entry for an entry on UrbanDictionary.\nUsage: `!urban <entry>`"

      match /urban (.+)/
      def lookup(word, channel, nick)
        begin
          url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}";
          o = Nokogiri::HTML(open(url));
          defword = CGI.unescape_html o.at("td.word").text.gsub(/\s+/, ' ');
          definition = CGI.unescape_html o.at("div.definition").text.gsub(/\s+/, ' ');
          #output = "#{defword.strip} -- #{definition.gsub(/^(.{#{510 - (": PRIVMSG :").bytesize - defword.strip.bytesize - url.bytesize - 16}}[^\s]*)(.*)/m) {$2.empty? ? $1 : $1 + '...'}} (#{url})";

          #Determining truncation length:
          tlen = 510 - (": PRIVMSG :").bytesize
          tlen = tlen - bot.mask.to_s.length - (channel || nick).length
          tlen = tlen - defword.strip.bytesize - url.bytesize - 10

          output = "#{defword.strip} -- #{awesome_truncate(definition, tlen)} (#{url})";
          definition != nil ? output : nil;
        rescue
          puts "#{$!}"
          nil
        end
      end

      def awesome_truncate(text, length = 30, truncate_string = "...")
        return if text.nil?
        l = length - truncate_string.bytesize
        text.bytesize > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
      end

      def execute(m, word)
        m.reply(lookup(word, m.channel.name, m.user.nick) || "No results found", false)
      end
    end
  end
end
