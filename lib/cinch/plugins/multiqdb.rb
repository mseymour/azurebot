# -*- coding: utf-8 -*-

#require 'zlib'

require_relative 'qdb/bash'
require_relative 'qdb/qdbus'
require_relative 'qdb/shakesoda'
require_relative 'qdb/mit'

module Cinch
  module Plugins
    class MultiQDB
      include Cinch::Plugin

      QDB_LINE_MARKS = {normal: '-', contd: '+', end: '$'}

      set(
      plugin_name: "QDB",
      help: "Pulls a quote from a QDB.\n`Usage: !qdb [selector] [#|latest|random]`; `!qdb` for selector list.",
      required_options: [:limit])

      def initialize(*args)
        super
        # Creating a hash of all QDB objects available.
        names = [QDB::Bash, QDB::QdbUS, QDB::Shakesoda, QDB::MIT].map {|qdb| [qdb.new.shortname, qdb] }
        @@qdbs = Hash[*names.flatten]
      end

      match /qdb(?: (\w+))?(?: (.+))?/, method: :execute_qdb, group: :x_qdb
      def execute_qdb(m, selector=nil, id=nil)
        m.reply "You have not supplied a selector. Selectors: #{@@qdbs.keys * ", "}" and return if !selector
        m.reply "#{selector} does not exist. Valid selectors: #{@@qdbs.keys * ", "}" and return if !@@qdbs.include?(selector)

        qdb = @@qdbs[selector].new # Instantize the QDB object

        result = fetch_qdb_obj(id, qdb)

        #rcolors = [:green, :red, :purple, :yellow, :lime, :teal, :aqua, :royal, :pink]
        #colorize_text = ->(text) { (Zlib::crc32(text) % rcolors.size)-1 }
        qdb_banner = "#{qdb.name} ##{result.id}"
        m.reply qdb_banner
        result.quote.each_with_index {|q,i|
          marker = if i.succ == result.quote.length then QDB_LINE_MARKS[:end]
          elsif i.succ == config[:limit] then QDB_LINE_MARKS[:contd]
          else QDB_LINE_MARKS[:normal]
          end

          if i.succ == config[:limit]
            # qdb public/private boundary
            m.reply "%s %s\nThe full quote can be viewed online at %s" % [marker, q, qdb.url + qdb.id_path_template % {id: result.id}]
            m.user.notice "%s continued:" % qdb_banner
          elsif i.succ > config[:limit]
            # qdb private
            m.user.notice "%s %s" % [marker, q]
          else
            # qdb public
            m.reply "%s %s" % [marker, q]
          end
        }
      rescue QDB::Error::QuoteNotFound => e
        m.reply e.message, true
      rescue OpenURI::HTTPError => e
        m.reply "An error has occured. #{$!}", true
      end

      match "qdb list", method: :execute_list
      def execute_list(m)
        list = []
        @@qdbs.each_value {|q|
          qdb = q.new
          list << "#{q.name} (#{q.shortname}): #{q.url}"
        }
        m.notice "To use a QDB, type " + Format(:bold, "!qdb [selector] [#|latest|random]") + ".\n" + list.join("\n")
      end

      private

      # @param id [Integer,String] The ID of the qdb entry. It may be an integer, a stringed integer with an octothorpe at the beginning (`#30`), `latest`, or `random`.
      # @param qdb [QDB::Base] The QDB object.
      def fetch_qdb_obj(id, qdb)
        case id
        when "latest" then qdb.latest
        when "random" then qdb.random
        when /^#?[[:digit:]]+$/ then qdb.by_id(id[/\d+/])
        else qdb.random
        end
      end

    end
  end
end
