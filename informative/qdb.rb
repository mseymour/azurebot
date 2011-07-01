# -*- coding: UTF-8 -*-

require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

class QDB
	include Cinch::Plugin
	plugin "qdb"
	help "qdb <id> -- Gets the item for the ss qdb"

	match /qdb (.+)/
	
	def lookup(id)
		begin
			url = "http://www.shakesoda.org/qdb/view/#{CGI.escape(id)}";
			o = Nokogiri::HTML(open(url));
			quotes = CGI.unescape_html o.at(".quote-content").children.to_s.gsub("\r","")
			quotes = quotes.split(/<br *\/?>/i)
			quotes != nil ? quotes : nil;
		rescue
			puts "#{$!}"
			nil
		end
	end

	def execute(m, id)
		arrquote = lookup(id)
		m.reply(arrquote[0..4].join("\n"));
	end
end