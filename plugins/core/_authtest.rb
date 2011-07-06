require 'cinch'
require_relative '../../modules/authenticate'

class AuthTest
	include Cinch::Plugin
	include Authenticate
	match %r{at}
	def execute m
		m.reply "This is an authenticated command..."
		if Auth::is_admin?(m.user)
			m.reply "You are an admin!"
		else
			m.reply "Get out you communist scum!"
		end
	end
end