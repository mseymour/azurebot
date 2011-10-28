# -*- coding: UTF-8 -*-

require 'plugins/qdb/bash'
require 'plugins/qdb/qdbus'
require 'plugins/qdb/shakesoda'

module Plugins

  class MultiQDB
    include Cinch::Plugin

    set(
    plugin_name: "QDB", 
    help: "Pulls a quote from a QDB.\n`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.")

    match /qdb\s?(\w+)?\s?(.+)?/
    
    @@selectors = {
      :bash => QDB::Bash,
      :us => QDB::Qdbus,
      :ss => QDB::Shakesoda,
    };
    
    #def generate_url( selector = nil, id = nil )
    def generate_quote( qdb_access, tail = false )
        output = []
        output << "#{qdb_access[:fullname]} quote ##{qdb_access[:id]} (#{qdb_access[:meta]}):" unless tail
        output <<  (!tail ? qdb_access[:quote].map {|e| "- #{e}" } : qdb_access[:quotetail].map {|e| "- #{e}" })

        footer = [] 
        footer << (qdb_access[:quote].size < qdb_access[:fullquote].size && !tail ? "#{qdb_access[:fullquote].size - qdb_access[:lines]} lines omitted." : nil)
        footer << "View"
        footer << (qdb_access[:quote].size < qdb_access[:fullquote].size && !tail ? "more from" : nil)
        footer << "this quote at #{qdb_access[:url]}"
        output << footer.reject(&:nil?).join(" ")
          
        output.reject(&:nil?).join("\n");
    end
    
    def generate_selector_list
      selectors = [];
      @@selectors.each {|key, value| selectors << key.to_s; }
      selectors[0..-2].join(", ") + ", and " + selectors[-1]
    end
      
    def execute (m, selector = nil, id = nil)
      retries = 3
      begin
        if (selector.nil? || @@selectors[selector.to_sym].nil?)
          m.reply "You have #{!id ? 'not listed a selector' : 'used an invalid selector'}. Valid selectors: %<selectors>s." % {:selectors => generate_selector_list()}
         else
          qdb_access = @@selectors[selector.to_sym].new(:id => id, :lines => 5).to_hsh;
          
          public_quote = generate_quote(qdb_access)
          m.reply(public_quote);
          
          if qdb_access[:fullquote].size > qdb_access[:quote].size
            sleep 2
            private_quote = generate_quote(qdb_access, true)
            m.user.notice("The rest of the quote:\n" + private_quote);
          end
        end
      rescue QDB::QuoteDoesNotExistError => e
        m.reply "It appears that quote ##{e.id} does not exist."
      rescue OpenURI::HTTPError => e
        m.reply "An error has occured. #{$!}"
      rescue Errno::ETIMEDOUT
        if retries > 0
          retries = retries.pred
          retry
        else m.reply "I cannot access the selected QDB (#{selector}, ##{id}) at the moment.", true
        end
      end
    end

  end

end