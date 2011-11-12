# -*- encoding: utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'obj_ext/string'

module Plugins
  class Alton
    include Cinch::Plugin

    set plugin_name: "Grandma Alton", help: "Do-It-Yourself Senile Grandma Alton's Tires Ad Generator (http://xkeeper.net/grandma.php)\nUsage: `!alton`"

    match /alton/i
    def execute m
      doc = Nokogiri::HTML(open('http://xkeeper.net/grandma.php'))
      line = doc.at("div").children.select {|n| n.text? and n.content }[1].text
      m.reply "![b]Grandma Alton:![b] #{line}".irc_colorize
    end

  end
end