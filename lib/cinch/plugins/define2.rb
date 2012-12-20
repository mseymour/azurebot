require_relative '../helpers/check_user'

module Cinch
  module Plugins
    class Define
      include Cinch::Plugin

      LAST_EDITED = "(last edited by %s at %s)"
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
          "I now know that #{Format(:bold,entry['term.case'])} is \"#{edited_entry['dfn']}\", rather than \"#{entry['dfn']}\"! #{LAST_EDITED}" % [entry['edited.by'], entry['edited.time']]
        }
      end

      match /forget (.+)/, method: :execute_forget
      def execute_forget(m, term)
        return m.reply(NOT_OP, true) unless check_user(m.channel, m.user)
        m.reply term_exists?(term) {|key, entry|
          shared[:redis].del key
          "I have forgotten #{Fomat(:bold,entry['term.case'])} which was \"#{entry['dfn']}\" #{LAST_EDITED}" % [entry['edited.by'], entry['edited.time']]
        }
      end

      match /whatis (.+)/, method: :execute_lookup, group: :lookup
      match /d (.+)/, method: :execute_lookup, prefix: /^\?/, group: :lookup
      def execute_lookup(m, term)
        m.reply term_exists?(term) {|key, entry|
          "#{Format(:bold,entry['term.case'])} is \"#{entry['dfn']}\" #{LAST_EDITED}" % [entry['edited.by'], entry['edited.time']]
        }
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