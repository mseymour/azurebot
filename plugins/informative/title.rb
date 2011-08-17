# -*- encoding: utf-8 -*-

# Copyright (c) 2010 Victor Bergöö
# This program is made available under the terms of the MIT License.
# Altered by Mark Seymour 2011-07-10 @ 12:27 AM

require 'nokogiri'
require 'curb'
require 'uri'
require 'cgi'

# Adapted/altered from https://github.com/netfeed/cinch-title/blob/master/lib/cinch/plugins/title.rb
class Title
	include Cinch::Plugin
	react_on :channel
	
	match /url (on|off)$/, method: :execute_onoff
	match /(.*http.*)/, method: :execute_uri, use_prefix: false
	
  def check_user?(users, user)
    user.refresh # be sure to refresh the data, or someone could steal the nick
    ["h", "o", "a", "q"].any? {|mode| users[user].include?(mode) }
  end
	
  def execute_onoff m, option
    begin
			return unless check_user?(m.channel.users, m.user)
				@urlreporting = option == "on"
				case option
					when "on"
						config[:enabled_channels] << m.channel.name
					else
						config[:enabled_channels].delete(m.channel.name)
				end
				m.reply "URI reporting for #{m.channel} is now #{@urlreporting ? 'enabled' : 'disabled'}!"
    rescue
      m.reply "Error: #{$!}"
    end
  end
	
	def execute_uri m, message
		return unless config[:enabled_channels].include?(m.channel.name)
		suffix =  m.user.nick[-1] == 's' ? "'" : "'s"

		URI.extract(message, ["http", "https"]) do |uri|
			begin
				next if ignore uri
				
				title = parse(uri)
				m.reply "#{m.user.nick}#{suffix} URL: #{title[0..(70 - m.user.nick.length - suffix.length - 6)]}"
			rescue URI::InvalidURIError => e
				@bot.debug "invalid url: #{uri}"
			end
		end
	end

	private

	def parse uri
		call = Curl::Easy.perform(uri) do |easy| 
			easy.follow_location = true
			easy.max_redirects = config["max_redirects"]
		end
		html = Nokogiri::HTML(call.body_str)
		title = html.at_xpath('//title')
		
		return "No title" if title.nil?
		CGI.unescape_html title.text.gsub(/\s+/, ' ')
	end
	
	def ignore uri
		ignore = ["jpg$", "JPG$", "jpeg$", "gif$", "png$", "bmp$", "pdf$", "jpe$"]
		ignore += config["ignore"] if config.key? "ignore"
		
		ignore.each do |re|
			return true if uri =~ /#{re}/
		end
		
		false
	end
end