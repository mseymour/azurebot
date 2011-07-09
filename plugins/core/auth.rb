# -*- coding: UTF-8 -*-

require_relative '../../modules/authenticate'

class Auth
	include Cinch::Plugin
	include Authenticate
	react_on :channel

	match /admin$/, method: :main_admin
	def main_admin(m)
		begin
			m.reply "#{Actions::main_admin(m.user)}"
		rescue
			m.reply "Oops, something went wrong."
			raise
		end
	end

	match /\+admin (.+)$/, method: :sub_admin
	def sub_admin(m, nick)
		begin
			m.reply "#{Actions::add_admin(User(@bot.nick), m.user, User(nick))}"
		rescue
			m.reply "Oops, something went wrong."
			puts "#{$@.split("\n")}"
			raise
		end
	end

	match /\-admin (.+)$/, method: :un_admin
	def un_admin(m, nick)
		begin
			m.reply "#{Actions::delete_admin(User(@bot.nick), m.user, User(nick))}"
		rescue
			m.reply "Oops, something went wrong."
			raise
		end
	end

	module Actions
		include Authenticate
		def Actions.main_admin origin
			a = Auth::Admin.first
			if a.nil?
				admin = Auth::Admin.new(:nick => origin.authname )
				admin.save
				"You are my owner, #{origin.nick}!"
			elsif Auth.is_admin?(origin)
				"Yay!"
			else
				"Who are you again?"
			end
		end
	
		def Actions.add_admin bot, origin, user
			return "Who are you again?" unless Auth.is_admin?(origin)
			return "It seems that person isn't online currently..." unless !user.nil?
			return "What are you trying to do, #{origin.nick}?" unless !user.nick.eql? bot.nick
			return "You are already an admin, #{origin.nick}." unless !origin.authname.eql? user.authname
			
			admin = Auth::Admin.new( :nick => user.authname )
			admin.save
			"Woohoo! #{user.nick} is an admin!"
		end
	
		def Actions.delete_admin bot, origin, user
			return "Who are you again?" unless Auth.is_admin?(origin)
			return "It seems that person isn't online currently..." unless !user.nil?
			return "What are you trying to do, #{origin.nick}?" unless !user.nick.eql? bot.nick
			return "You can't unadmin yourself, #{origin.nick}." unless !origin.authname.eql? user.authname
			
			admin = Auth::Admin.first( :nick => user.authname )
			return "It seems that person is not an admin." if admin.nil?
			admin.destroy
			"And good riddance to you, #{user.nick}."
		end
	end


end