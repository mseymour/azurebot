# -*- coding: UTF-8 -*-

require 'open-uri'
require 'nokogiri'
require 'cgi'

module Plugins
  class JargonFile
    include Cinch::Plugin
    set help: "!jargon <entry> -- Gets the entry from the Jargon File."
    
    match /jargon (.+)/
    def lookup(word)
      begin
        x = word[0].gsub(/([\(\/124@])/,'0').upcase;
        
        term = word;
        #special cases for when the filename is different than the title
        case term
          when /^([\(])/
            term.gsub!(/^([\(])/,'');
            term.gsub!(/([\)]$)/,''); #hackety hack
          when /^([\/])/
            term.gsub!(/^([\/])/,'');
          when /([\s\W]+$)/
            term.gsub!(/([\s\W]+$)/,'');
          when /^([0])/
            term.gsub!(/^([0])/,'numeral-zero');
          when /^([1])/
            term.gsub!(/^([1])/,'one-');
          when /^([2])/
            term.gsub!(/^([2])/,'infix-two');
          when /^([4])/
            term.gsub!(/^([4])/,'code-4');
          when /^([@])/
            term.gsub!(/^([@])/,'at');
          when /([\*])/
            term.gsub!(/([\*])/,'-asterisk-');
        end
        
        term.gsub!(/([\s\W])/,'-');
        
        #url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
        url = "http://www.catb.org/jargon/html/#{x}/#{term}.html"
        page = Nokogiri::HTML(open(url));
        key = CGI.unescape_html page.at("dt##{term}").text.gsub(/\s+/, ' ') rescue nil
        definition = CGI.unescape_html page.at("dd > p").text.gsub(/\s+/, ' ') rescue nil
        output = "#{key} -- #{definition.gsub(/^(.{100}[^\s]*)(.*)/m) {$2.empty? ? $1 : $1 + '…'}} (#{url})";
        definition != nil ? output : nil;
      rescue OpenURI::HTTPError => err
        "I couldn't find that! Did you misspell it? Make sure that all words are capitalized properly."
      end
    end

    def execute(m, word)
      m.reply(lookup(word) || "No results found", false)
    end
  end
end