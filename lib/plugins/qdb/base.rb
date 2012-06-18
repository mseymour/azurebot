require 'open-uri'
require 'nokogiri'
require 'cgi'

module QDB

  module Error
    class QuoteNotFound < StandardError; attr :id; def initialize(id); @id = id; end; end;
  end

  class Base
    attr_reader :name, :shortname, :url, :id_path_template, :random_path, :latest_path

    Quote = Struct.new(:id, :quote) # Quote object for using in returning quote data

    def initialize
    end

    def by_id(id); raise "#{__method__} must be overridden."; end;

    def random # This can be overridden if needed.
      self.by_id(@url + @random_path)
    end

    def latest # This can be overridden if needed.
      self.by_id(@url + @latest_path)
    end

  end
end