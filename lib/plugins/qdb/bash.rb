# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

require_relative 'base'

module QDB

	class Bash < Base
		def initialize *args
			@fullname = "Bash.org"
			@base_url = "http://bash.org/"
			@path_template = "?%<id>s"
			super
		end
		
		def retrieve_latest_quote_id
			url = "#{@base_url}?latest"
			o = Nokogiri::HTML(open(url));
			id = CGI.unescape_html o.at(".quote a b").children.to_s.strip.gsub("\r","").gsub("#","")
			id.to_s
		end
	
		def retrieve_quote params={}
			params = { lines: @lines }.merge(params)

			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".qt").nil?
			quotes = CGI.unescape_html o.at(".qt").children.to_s.gsub(/[\r\n]/,"")
			quotes = quotes.split(/<br *\/?>/i)
			
			params[:lines] > -1 ? quotes[0..params[:lines]-1] : quotes[0..params[:lines]]
		end
	
		def retrieve_meta
			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".quote").nil?
			rating = o.at(".quote").children.to_s.match(/\((-?\d+)\)/)[1]
			
			"Rating: #{rating}"
		end
	end

end