# -*- encoding: utf-8 -*-

require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Alton
      include Cinch::Plugin

      set plugin_name: "Grandma Alton", help: "Do-It-Yourself Senile Grandma Alton's Tires Ad Generator (http://xkeeper.net/grandma.php)\nUsage: `!alton`"

      match 'alton'
      def execute(m)
        doc = Nokogiri::HTML(open('http://xkeeper.net/grandma.php'))
        line = doc.at("div").children.select {|n| n.text? and n.content }[1].text
        m.reply Format(:bold,"Grandma Alton:") + " \"#{line}\""
      end

    end
  end
end
