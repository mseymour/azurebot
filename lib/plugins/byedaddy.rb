# coding: utf-8

require 'open-uri'
require 'json'
require 'cgi'

module Plugins
  class ByeDaddy
    include Cinch::Plugin

    set plugin_name: "ByeDaddy", help: "Check if a website is registered with GoDaddy via ByeDaddy's API.\nUsage: `!byedaddy [uri]` - Does this site use GoDaddy?\nUsage: `!byedaddy top` - Lists the top 10 websites still using GoDaddy."

    match /byedaddy (.+)/, method: :execute
    def execute m, a_uri
      api_uri = "http://byedaddy.org/api" + (a_uri.casecmp("top") == 0 ? "/top" : "/url/#{CGI::escape(a_uri.match(/.+\..+/) ? a_uri : a_uri+".com")}")
      response = JSON.parse(open(api_uri,&:read))
      if a_uri.casecmp("top") == 0
        m.reply "The top 10 current GoDaddy users: #{response[0..-2].join(", ") + ", and " + response[-1]}."
      else
        m.reply "#{response["domain"]} is #{response["result"] ? "still using GoDaddy! Boo!" : "not using GoDaddy! Yay!"}", true
      end
    end

  end
end