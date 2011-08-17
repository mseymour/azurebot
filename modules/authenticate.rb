require "dm-core"
require "dm-types"

module Authenticate
	class Auth
		class Admin
			include DataMapper::Resource
			property :id, Serial
			property :nick, String
		end 
		DataMapper.finalize
		
		def Auth.is_admin?(user)
			a = Admin.first(:nick => user.authname)
			not a.nil?
		end
	
		def Auth.head_admin
			Admin.first[:nick].to_s
		end
	end

end