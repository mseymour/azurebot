# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

require_relative 'base'

module QDB

	class Shakesoda < Base
		def initialize *args
			@fullname = "#shakesoda QDB"
			@base_url = "http://www.shakesoda.org/qdb/"
			@path_template = "view/%<id>s"
			super
		end
		
		def retrieve_latest_quote_id
			url = "#{@base_url}"
			o = Nokogiri::HTML(open(url));
			id = CGI.unescape_html o.at(".quote .quote-header a").children.to_s.strip.gsub("\r","").gsub("#","")
			id.to_s
		end
	
		def retrieve_quote params={}
			params = { lines: @lines }.merge(params)

			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".quote").nil?
			quotes = CGI.unescape_html o.at(".quote-content").children.to_s.gsub("\r","")
			quotes = quotes.split(/<br *\/?>/i)
			
			params[:lines] > -1 ? quotes[0..params[:lines]-1] : quotes[0..params[:lines]]
		end
	
		def retrieve_meta
			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".quote").nil?
			rating = CGI.unescape_html o.at(".quote-header").children.to_s.gsub("\r","").split(".")[0]
			
			"#{rating}"
		end
	end

end