# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

require_relative 'base'

module QDB

	class Qdbus < Base
		def initialize *args
			@fullname = "Qdb.us"
			@base_url = "http://qdb.us/"
			super
		end
		
		def retrieve_latest_quote_id
			url = "#{@base_url}"
			o = Nokogiri::HTML(open(url));
			id = CGI.unescape_html o.at(".q .ql").children.to_s.strip.gsub("\r","").gsub("#","")
			id.to_i
		end
	
		def retrieve_quote params={}
			id = params[:id]||:latest;
			lines = params[:lines]||0;
			@id = (:"#{id}" == :latest || id.nil? ? self.retrieve_latest_quote_id : id)
			
			@url = "#{@base_url}#{id}"
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
			raise QDB::QuoteDoesNotExistError, "Quote ##{@id} does not exist." if o.at(".qt").nil?
			rating_qs = CGI.unescape_html o.at(".q b span").children.to_s
			rating_qvc = CGI.unescape_html o.at(".q > span").children.to_s
			
			"Rating: #{rating_qs}#{rating_qvc}"
		end
	end

end