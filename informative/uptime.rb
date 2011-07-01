# -*- coding: UTF-8 -*-

require 'cinch'
require 'active_support'
require 'active_support/core_ext'
require 'ruby-wmi'
require 'socket'

class Uptime
  include Cinch::Plugin
	
	match %r/uptime/
	
	def uptime!
		lastBootupTime = WMI::Win32_OperatingSystem.find(:first).LastBootupTime
		boot = DateTime.strptime(lastBootupTime, "%Y%m%d%H%M")

		"My host computer, \"#{Socket.gethostname}\", has been running for #{time_diff_in_natural_language(boot, Time.now)}."
	end
	
  def time_diff_in_natural_language(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []

		%w(year month day hour minute second).map do |interval|
			distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
			delta = (distance_in_seconds / 1.send(interval)).floor
			delta -= 1 if from_time + delta.send(interval) > to_time
			from_time += delta.send(interval)
			components << "#{delta} #{delta > 1 ? interval.pluralize : interval}" if delta > 0
    end
    components.join(", ")
  end
	
	def execute (m)
		m.reply(uptime!);
	end

end