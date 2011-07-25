# -*- coding: UTF-8 -*-

require_relative '../../modules/stringhelpers'
require 'active_support'
require 'active_support/core_ext'
require 'ruby-wmi'
require 'socket'

class Uptime
  include Cinch::Plugin
	include StringHelpers
	
	match %r/uptime/
	
	def uptime!
		lastBootupTime = WMI::Win32_OperatingSystem.find(:first).LastBootupTime
		boot = DateTime.strptime(lastBootupTime, "%Y%m%d%H%M")

		"My host computer, \"#{Socket.gethostname}\", has been running for #{time_diff_in_natural_language(boot, Time.now)}."
	end
	
	def execute (m)
		m.reply(uptime!);
	end

end