# -*- coding: UTF-8 -*-

require 'cinch'
require 'date'
require 'net/ftp'
require 'json'

class Featurerequest
  include Cinch::Plugin
	plugin "request"
	help "request <feature> -- Submits a feature request to be reviewed by my owner."
	
	attr_accessor :local_path, :remote_path, :filename, :uri

	match /requpdate$/, method: :execute_updaterequest
	match /request (.+)$/, method: :execute_request
	
	def initialize(bot)
		super;
		@local_path = "C:\\Users\\Mark Seymour\\Desktop\\bot\\";
		@remote_path = '/lain.rustedlogic.net/requests/';
		@filename = 'bot_requests.json';
		@uri = 'http://lain.rustedlogic.net/requests/';
	end
	
	def add_request(channel, server, nick, request)
		bot_request_file = "#{@local_path}#{@filename}";
		t = DateTime.now();
		
		document = "";
		
		File.open(bot_request_file, 'r') {|f|
				f.each {|line|
					document << line
				}
				#p document
		}
		jsonary = JSON.parse(document)
		p jsonary
		
		#File.open(bot_request_file, 'a') {|f| f.write("[  ] -- #{t.strftime("%B %d %Y @ %r")} -- #{channel}@#{server} -- #{nick} requests: #{request}\n")}
	end
	
	def update_remote_display
		bot_request_file = "#{@local_path}#{@filename}";
		Net::FTP.open('rustedlogic.net','azuretan','Pip9LFrT') do |ftp|
			files = ftp.chdir(@remote_path)
			files = ftp.list('n*')
			ftp.puttextfile(bot_request_file, @filename)
			ftp.close
		end
	end
	
  def execute_request(m, request)
		add_request(m.channel.name, @bot.config.server, m.user.nick, request);
		m.user.notice("Your feature request has been submitted!");
		update_remote_display()
		m.user.notice("The feature list has been successfully updated! (#{@uri})");
  end

	def execute_updaterequest(m)
		update_remote_display()
		m.user.notice("The feature list has been successfully updated! (#{@uri})");		
	end

end