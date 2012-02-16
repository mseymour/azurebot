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
      @path_template = "?%<id>s"
      super
    end

    def retrieve_latest_quote_id
      url = "#{@base_url}"
      o = Nokogiri::HTML(open(url));
      id = CGI.unescape_html o.at(".q .ql").children.to_s.strip.gsub("\r","").gsub("#","")
      id.to_s
    end

    def retrieve_quote params={}
      params = { lines: @lines }.merge(params)

      o = Nokogiri::HTML(open(@url))
      raise QDB::QuoteDoesNotExistError.new(@id), "Quote ##{@id} does not exist." if o.at(".qt").nil?
      quotes = CGI.unescape_html o.at(".qt").children.to_s.gsub(/[\r\n]/,"")
      quotes = quotes.split(/<br *\/?>/i)

      params[:lines] > -1 ? quotes[0..params[:lines]-1] : quotes[0..params[:lines]]
    end

    def retrieve_meta
      o = Nokogiri::HTML(open(@url))
      raise QDB::QuoteDoesNotExistError.new(@id), "Quote ##{@id} does not exist." if o.at(".qt").nil?
      rating_qs = CGI.unescape_html o.at(".q b span").children.to_s
      rating_qvc = CGI.unescape_html o.at(".q > span").children.to_s

      "Rating: #{rating_qs}#{rating_qvc}"
    end
  end

end
