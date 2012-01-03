# -*- coding: UTF-8 -*-

require_relative '../modules/stringhelpers'
require 'ruby-wmi'
require 'socket'

module Plugins
  class Uptime
    include Cinch::Plugin
    include StringHelpers
    
    set plugin_name: "Uptime", help: "Gets the uptime of the bot's host. (Uses WMI.)\nUsage: `!uptime`"

    def uptime!
      lastBootupTime = WMI::Win32_OperatingSystem.find(:first).LastBootupTime
      boot = DateTime.strptime(lastBootupTime, "%Y%m%d%H%M")

      "My host computer, \"#{Socket.gethostname}\", has been running for #{time_diff_in_natural_language(boot, Time.now)}."
    end
    
    match %r/uptime/
    def execute (m)
      m.reply(uptime!);
    end
  end
end