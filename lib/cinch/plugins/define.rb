require_relative "../admin"
require_relative '../helpers/check_user'
require 'chronic_duration'
require 'json'
require 'tempfile'

module Cinch
  module Plugins
    class Define
      include Cinch::Plugin
      include Cinch::Admin

      LAST_EDITED = "(last edited by %s, %s ago)"
      DOES_NOT_EXIST = "I do not know what \"%s\" is."
      NOT_OP = "You do not have the proper access! (not +qaoh)"

      match /define (.+?) as (.+)/, method: :execute_define
      def execute_define(m, term, dfn)
        if shared[:redis].exists("term:"+term.downcase)
          execute_redefine(m, term, dfn) # pass to redefine
        else
          # create new dfn
          entry = {
            "term.case" => term, 
            "dfn" => dfn, 
            "edited.by" => m.user.nick, 
            "edited.time" => Time.now.to_s
          }
          shared[:redis].hmset "term:#{term.downcase}", *entry
          m.reply "I now know that #{Format(:bold,entry['term.case'])} is \"#{entry['dfn']}\"!"
        end
      end

      match /redefine (.+?) as (.+)/, method: :execute_redefine
      def execute_redefine(m, term, dfn)
        return m.reply(NOT_OP, true) unless check_user(m.channel, m.user)
        m.reply term_exists?(term) {|key, entry|
          edited_entry = entry.merge 'dfn' => dfn, 'edited.by' => m.user.nick, 'edited.time' => Time.now.to_s
          shared[:redis].hmset key, *edited_entry
          edited_time = ChronicDuration.output(Time.now.to_i - Time.parse(entry["edited.time"]).to_i)
          "I now know that #{Format(:bold,entry['term.case'])} is \"#{edited_entry['dfn']}\", rather than \"#{entry['dfn']}\"! #{LAST_EDITED}" % [entry['edited.by'], edited_time]
        }
      end

      match /forget (.+)/, method: :execute_forget
      def execute_forget(m, term)
        return m.reply(NOT_OP, true) unless check_user(m.channel, m.user)
        m.reply term_exists?(term) {|key, entry|
          shared[:redis].del key
          edited_time = ChronicDuration.output(Time.now.to_i - Time.parse(entry["edited.time"]).to_i)
          "I have forgotten #{Format(:bold,entry['term.case'])} which was \"#{entry['dfn']}\" #{LAST_EDITED}" % [entry['edited.by'], edited_time]
        }
      end

      match /whatis (.+)/, method: :execute_lookup, group: :lookup
      match /d (.+)/, method: :execute_lookup, prefix: /^\?/, group: :lookup
      def execute_lookup(m, term)
        m.reply term_exists?(term) {|key, entry|
          edited_time = ChronicDuration.output(Time.now.to_i - Time.parse(entry["edited.time"]).to_i)
          "#{Format(:bold,entry['term.case'])} is \"#{entry['dfn']}\" #{LAST_EDITED}" % [entry['edited.by'], edited_time]
        }
      end

      match 'getdefs', method: :execute_getdefs
      def execute_getdefs(m)
        return unless is_admin?(m.user)
        keys = shared[:redis].keys('term:*');
        defs = keys.map {|key|
          shared[:redis].hgetall(key)
        }

        file = Tempfile.new ["#{@bot.nick}_definitions_#{Time.now.to_i}", ".json"]
        begin
          file.write defs.to_json
          file.close
          m.user.dcc_send(file.open(), "#{@bot.nick}_definitions_#{Time.now.to_i}.json")
        ensure
          file.unlink
        end
      end

      private

      def term_exists?(term)
        if shared[:redis].exists("term:"+term.downcase)
          yield "term:"+term.downcase, shared[:redis].hgetall("term:"+term.downcase)
        else
          DOES_NOT_EXIST % term
        end
      end

    end
  end
end