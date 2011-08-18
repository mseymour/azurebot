# -*- coding: UTF-8 -*-

require_relative 'qdb/bash'
require_relative 'qdb/qdbus'
require_relative 'qdb/shakesoda'

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
	
	def generate_url( selector = nil, id = nil )
		return nil if (selector.nil? || @@selectors[selector.to_sym].nil?);
		#return get_base_url(@@selectors[selector.to_sym]) if (is.nil? || tags.empty?);
		begin
			qdb_access = @@selectors[selector.to_sym].new(:id => id, :lines => 5).to_hsh;
			
			output = []
			output << "#{qdb_access[:fullname]} quote ##{qdb_access[:id]} (#{qdb_access[:meta]}):"
			output << qdb_access[:quote].map {|e| "- #{e}" }

			footer = [] 
			footer << (qdb_access[:lines] > qdb_access[:quote].size ? "#{qdb_access[:lines] - qdb_access[:quote].size} lines omitted." : nil)
			footer << "View"
			footer << (qdb_access[:lines] > qdb_access[:quote].size ? "more from" : nil)
			footer << "this quote at #{qdb_access[:url]}"
			output << footer.reject(&:nil?).join(" ")
				
			output.reject(&:nil?).join("\n");
		rescue
			"Error: #{$!}"
		end
	end
	
	def generate_selector_list
		selectors = [];
		@@selectors.each {|key, value| selectors << key.to_s; }
		selectors[0..-2].join(", ") + ", and " + selectors[-1]
	end
		
	def execute (m, selector, id)
		m.reply(generate_url(selector, id) || "You have #{!id ? 'not listed a selector' : 'used an invalid selector'}. Valid selectors: %<selectors>s." % {:selectors => generate_selector_list()});
	end

end