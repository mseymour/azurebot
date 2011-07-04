# -*- coding: UTF-8 -*-

require 'cinch'

class Booru
  include Cinch::Plugin

	match /booru\s?(\w+)?\s?(.+)?/
	
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
		@@selectors[selector.to_sym] % {:tags => CGI::escape(list_to_tags(tags))};
	end
		
	def generate_selector_list
		selectors = [];
		@@selectors.each {|key, value| selectors << key.to_s; }
		selectors[0..-2].join(", ") + ", and " + selectors[-1]
	end
		
	def execute (m, selector, tags)
		m.reply(generate_url(selector, tags) || "You have #{!tags ? 'listed no tags' : 'used an invalid selector'}. Valid selectors: %<selectors>s." % {:selectors => generate_selector_list()}, true);
	end

end