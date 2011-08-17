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
			super
		end
		
		def retrieve_latest_quote_id
			url = "#{@base_url}?latest"
			o = Nokogiri::HTML(open(url));
			id = CGI.unescape_html o.at(".quote a b").children.to_s.strip.gsub("\r","").gsub("#","")
			id.to_i
		end
	
		def retrieve_quote params={}
			id = params[:id]||:latest;
			lines = params[:lines]||4;
			@id = (:"#{id}" == :latest || id.nil? ? self.retrieve_latest_quote_id : id)
			
			@url = "#{@base_url}?#{id}"
			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".qt").nil?
			quotes = CGI.unescape_html o.at(".qt").children.to_s.gsub(/[\r\n]/,"")
			quotes = quotes.split(/<br *\/?>/i)
			@lines = quotes.size
			
			quotes[0..lines-1]
		end
	
		def retrieve_meta params={}
			id = params[:id]||:latest;
			@id = (:"#{id}" == :latest || id.nil? ? self.retrieve_latest_quote_id : id)
			
			@url = "#{@base_url}?#{id}"
			o = Nokogiri::HTML(open(@url))
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".quote").nil?
			rating = o.at(".quote").children.to_s.match(/\((-?\d+)\)/)[1]
			
			"Rating: #{rating}"
		end
	end

end