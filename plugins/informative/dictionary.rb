# -*- coding: UTF-8 -*-

# BIG WARNING: This plugin may or may not work correctly.
# I have not done much development on it for a while, so it may or may not be
# really buggy.

require 'open-uri'
require 'nokogiri'
require 'cgi'

class Dictionary
  include Cinch::Plugin

  match /dict (.+)/
  def lookup(word)
    url = "http://dictionary.reference.com/browse/#{CGI.escape(word)}"
    CGI.unescape_html Nokogiri::HTML(open(url)).at("div.luna-Ent").text.gsub(/\s+/, ' ') rescue nil
  end

  def execute(m, word)
    m.reply(lookup(word) || "No results found", true)
  end
end