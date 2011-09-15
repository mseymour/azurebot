# -*- coding: UTF-8 -*-
require 'modules/helpers/table_format'

module Plugins
	class Booru
		include Cinch::Plugin

		set(
			plugin_name: "Booru",
			help: "Generates a handy link to a *booru search\nUsage: `!booru <selector> <comma-separated list of tags>`; use `!booru` to get a list of tags.")

		@@selectors = {
			:dan => "http://danbooru.donmai.us/post?tags=%<tags>s",
			:gel => "http://gelbooru.com/index.php?page=post&s=list&tags=%<tags>s",
			:safe => "http://safebooru.com/index.php?page=post&s=list&tags=%<tags>s",
			:kona => "http://konachan.com/post?tags=%<tags>s",
			:oreno => "http://oreno.imouto.org/post?tags=%<tags>s&searchDefault=Search",
			:"4walled" => "http://4walled.org/search.php?tags=%<tags>s&board=&width_aspect=&searchstyle=larger&sfw=&search=search",
			:"3d" => "http://behoimi.org/post?tags=%<tags>s",
			:e621 => "http://e621.net/post?tags=%<tags>s",
			:nano => "http://booru.nanochan.org/post/list/%<tags>s/1",
			:pony => "http://ponibooru.413chan.net/post/list/%<tags>s/1",
			:rule34 => "http://rule34.paheal.net/post/list/%<tags>s/1",
			:katawa => "http://shimmie.katawa-shoujo.com/post/list/%<tags>s/1",
			:monster => "http://monstergirlbooru.com/index.php?q=/post/list/%<tags>s/1"
		};

		def get_base_url(src)
			src.match(%r{^(http://.+?/)})[0];
		end

		def list_to_tags( list )
			list.split(", ").uniq.map {|e| e.gsub %r{\s}, "_"}.join(" ");
		end

		def generate_url( selector, tags )
			return nil if (selector.nil? || @@selectors[selector.to_sym].nil?);
			return get_base_url(@@selectors[selector.to_sym]) if (tags.nil? || tags.empty?);
			@@selectors[selector.to_sym] % {:tags => CGI::escape(tags)};
		end
			
		def generate_selector_list
			selectors = [];
			@@selectors.each {|key, value| selectors << key.to_s; }
			selectors[0..-2].join(", ") + ", and " + selectors[-1]
		end
		
    match /booru$/, method: :execute_booru
		match /booru (\w+)?\s?(.+)?/, method: :execute_booru
		def execute_booru (m, selector = nil, tags = nil)
			m.reply(generate_url(selector, tags) || "You have #{!tags ? 'listed no tags' : 'used an invalid selector'}. Valid selectors: %<selectors>s." % {:selectors => generate_selector_list()}, true);
		end

    match /boorulist/, method: :execute_boorulist
    def execute_boorulist m
      table_array = []
      @@selectors.each {|k,v|
        table_array << "#{k}\t#{get_base_url(v)}"
      }
      m.user.notice Helpers::table_format(table_array, justify: [:right, :left], headers: ["selector","url"], gutter: 1)
    end

	end
end