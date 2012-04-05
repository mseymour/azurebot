# -*- coding: utf-8 -*-

require 'uri'

module QDB
  class QuoteDoesNotExistError < StandardError
    attr :id
    def initialize(id)
      @id = id
    end
  end

  class Base
    attr_reader :fullname
    attr_accessor :id
    attr_reader :lines
    attr_reader :url

    def initialize(params={})
      params = {
        id: :latest,
        lines: 4
      }.merge(params)

      raise "@fullname must be set in #{self.class.name}#initialize." if @fullname.nil?
      raise "@base_url must be set in #{self.class.name}#initialize." if @base_url.nil?
      raise "@path_template must be set in #{self.class.name}#initialize." if @path_template.nil?
      @base_url.freeze # This prevents the developer from screwing around with the variable.

      @id = (:"#{params[:id]}" == :latest || params[:id].nil? ? self.retrieve_latest_quote_id : params[:id])
      @id.gsub(/^#/, '') if @id.is_a?(String) # removing hashes from beginning of value, if string
      @lines = params[:lines]
      @url = "#{@base_url}#{ @path_template % { id: URI.escape(@id, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) } }"
    end

    def retrieve_latest_quote_id
      raise "retrieve_latest_quote_id must be overridden."
    end

    def retrieve_quote(params={})
      raise "retrieve_quote must be overridden."
    end

    def retrieve_meta(params={})
      raise "retrieve_meta must be overridden."
    end

    def to_hsh
      retrieved_quote = self.retrieve_quote lines: -1
      {
        fullname: @fullname,
        quote: retrieved_quote[0..@lines-1],
        quotetail: retrieved_quote[@lines..-1],
        fullquote: retrieved_quote,
        meta: self.retrieve_meta,
        id: @id,
        lines: @lines,
        url: @url
      }
    end

  end
end
