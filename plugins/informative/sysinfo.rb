# -*- coding: UTF-8 -*-

require_relative '../_ext/string'
require_relative '../../modules/stringhelpers'
require 'active_support/core_ext'
require 'ruby-wmi'
require 'socket'

class Sysinfo_Windows
  include Cinch::Plugin
	include StringHelpers
	
	prefix /^~/
	match %r/sysinfo/

=begin
	def print_properties wmiobj
		wmiobj.properties_.each{|p| puts "\t #{p.name.ljust(43,".")} #{wmiobj.send(:"#{p.name}")}" }
	end
=end

	def get_disks *args
		disks = []
		args.each {|arg|
			disks << WMI::Win32_LogicalDisk.find(:first, :conditions => {'Name' => arg})
		}
		return disks
	end

	def to_pc n, d
		n = n.to_f
		d = d.to_f
		(n/d)*100
	end

	def kilo n
		n = n.to_f
		count = 0
		while  n >= 1024 and count < 4
			n /= 1024.0
			count += 1
		end
		format("%.2f",n) + %w(B KB MB GB TB)[count]
	end

	def info!
		os = WMI::Win32_OperatingSystem.find(:first)
		cs = WMI::Win32_ComputerSystem.find(:first)
		proc = WMI::Win32_Processor.find(:first)
		procpf = WMI::Win32_PerfFormattedData_PerfOS_Processor.find(:first, :host => Socket.gethostname)
		mem = WMI::Win32_PerfFormattedData_PerfOS_Memory.find(:first, :host => Socket.gethostname)
		serv = WMI::Win32_PerfRawData_PerfNet_Server.find(:first, :host => Socket.gethostname)

		info = []

		info << "![b]Hostname:![b] #{Socket.gethostname}"

		info << "![b]OS:![b] #{os.caption}"

		info << "![b]CPU![b]: #{proc.name.gsub(%r{\(.+?\)},"").split.join(" ")}"

		info << "![b]Processes:![b] #{os.NumberOfProcesses}"

		bootup_time = DateTime.strptime(os.lastbootuptime, "%Y%m%d%H%M")
		info << "![b]Uptime:![b] #{time_diff_in_natural_language(bootup_time, Time.now, true)}"

		info << "![b]Users:![b] #{serv.serversessions}"

		info << "![b]Load Average:![b] #{(100 - procpf.percentidletime.to_f) / 100}"

		memory_used = kilo(cs.totalphysicalmemory.to_f - mem.availablebytes.to_f)
		memory_total = kilo(cs.totalphysicalmemory)
		memory_percent = to_pc(cs.totalphysicalmemory.to_f - mem.availablebytes.to_f, cs.totalphysicalmemory.to_f).round(2)
		info << "![b]Memory Usage:![b] #{memory_used}/#{memory_total} (#{memory_percent}%)"

		disk_info = get_disks("c:").map{|x| "(#{x.name}) #{kilo(x.size.to_f - x.freespace.to_f)}/#{kilo(x.size.to_f)} (#{to_pc(x.size.to_f - x.freespace.to_f, x.size).round(2)}%)"}.join(", ")
		info << "![b]Disk Usage:![b] #{disk_info}"

		info.map(&:strip).join(" - ")
	end
	
	def execute (m)
		m.reply(info!.irc_colorize);
	end

end