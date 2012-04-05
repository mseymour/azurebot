# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

require_relative 'base'

module QDB

  class Shakesoda < Base
    def initialize(*args)
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

    def retrieve_quote(params={})
      params = { lines: @lines }.merge(params)

      o = Nokogiri::HTML(open(@url))
      raise QDB::QuoteDoesNotExistError.new(@id), "Quote ##{@id} does not exist." if o.at(".quote").nil?
      quotes = CGI.unescape_html o.at(".quote-content").children.to_s.gsub("\r","")
      quotes = quotes.split(/<br *\/?>/i)

      params[:lines] > -1 ? quotes[0..params[:lines]-1] : quotes[0..params[:lines]]
    end

    def retrieve_meta
      o = Nokogiri::HTML(open(@url))
      raise QDB::QuoteDoesNotExistError.new(@id), "Quote ##{@id} does not exist." if o.at(".quote").nil?
      
      score = o.xpath('//div[@class="quote-header"]/span[@class="score"]')[0].content
      subscore_up = o.xpath('//div[@class="quote-header"]/span[@class="subscores"]/a[@class="upvotes"]')[0].content
      subscore_down = o.xpath('//div[@class="quote-header"]/span[@class="subscores"]/a[@class="downvotes"]')[0].content

      "#{score} (#{subscore_up}/#{subscore_down})"
    end
  end

end
