# -*- coding: utf-8 -*-

require 'zlib'

require_relative 'qdb/bash'
require_relative 'qdb/qdbus'
require_relative 'qdb/shakesoda'
require_relative 'qdb/mit'

module Cinch
  module Plugins
    class MultiQDB
      include Cinch::Plugin

      set(
      plugin_name: "QDB",
      help: "Pulls a quote from a QDB.\n`Usage: !qdb <selector> <ID|latest|random>`; `!qdb` for selector list.",
      required_options: [:limit])

      def initialize *args
        super
        # Creating a hash of all QDB objects available.
        names = [QDB::Bash, QDB::QdbUS, QDB::Shakesoda, QDB::MIT].map {|qdb| [qdb.new.shortname, qdb] }
        @@qdbs = Hash[*names.flatten]
      end

      match /qdb\s?(\w+)?\s?(.+)?/, method: :execute_qdb
      def execute_qdb m, selector, id
        m.reply "You have not supplied a selector. Selectors: #{@@qdbs.keys * ", "}" and return if !selector
        m.reply "#{selector} does not exist. Valid selectors: #{@@qdbs.keys * ", "}" and return if !@@qdbs.include?(selector)

        qdb = @@qdbs[selector].new # Instantize the QDB object

        result = case id
        when "latest" then qdb.latest
        when "random" then qdb.random
        when /^#?[[:digit:]]+$/ then qdb.by_id(id.gsub(/\D+/, ''))
        else
          qdb.random
        end

        banner = "#{qdb.name} ##{result.id}"
        #rcolors = [:green, :red, :purple, :yellow, :lime, :teal, :aqua, :royal, :pink]
        #colorize_text = ->(text) { (Zlib::crc32(text) % rcolors.size)-1 }
        m.reply banner
        result.quote.each_with_index {|q,i|
          is_at_limit = -> {i+1 == config[:limit] && config[:limit] < result.quote.size}
          if (1..config[:limit]).include?(i+1)
            m.reply "#{is_at_limit.call ? "+" : "-"} #{q}"
            m.reply "The full quote can be viewed online at #{qdb.url + qdb.id_path_template % {id: result.id}}." if is_at_limit.call
          else
            m.user.notice "#{banner} continued:" if i+1 == config[:limit]+1
            bar = -> {i+1 == config[:limit]+1}
            m.user.notice "- " + q
          end
        }
      rescue QDB::Error::QuoteNotFound => e
        m.reply e.message, true
      rescue OpenURI::HTTPError => e
        m.reply "An error has occured. #{$!}", true
      rescue Errno::ETIMEDOUT
        if retries > 0
          retries = retries.pred
          retry
        else m.reply "I cannot access the selected QDB (#{selector}, ##{id}) at the moment. Please try again later.", true
        end
      end

      match "qdb list", method: :execute_list
      def execute_list m
        list = []
        @@qdbs.each_value {|q|
          qdb = q.new
          list << "#{q.name} (#{q.shortname}): #{q.url}"
        }
        m.notice "To use a QDB, type " + Format(:bold, "!qdb <selector> <ID|latest|random>") + ".\n" + list.join("\n")
      end

    end
  end
end
