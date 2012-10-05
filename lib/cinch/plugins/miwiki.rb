# coding: utf-8
require_relative 'miwiki/wikipedia'

module Cinch
  module Plugins
    class Miwiki
      include Cinch::Plugin

      match /wiki (.+)/
      def execute(m, search)
        miyuki = Wikipedia.new
        excerpt = miyuki.fetch(search)
        m.reply "#{Format(:bold, excerpt.title)}\n#{excerpt.summary}¶\n#{excerpt.title_to_url}"
      rescue => e
       m.reply "#{Format(:pink, :bold, 'Uhoh!')} · #{e.message}" 
      end
    end
  end
end