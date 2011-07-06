require "dm-core"
require "dm-types"
require "dm-migrations"
	
module Database
	
	def Database.setup! (dbfile)
		raise "No database selected!" if dbfile == nil
				
		DataMapper::Logger.new($stdout, :debug)
		DataMapper.setup(:default, { :adapter => 'sqlite', :path => dbfile })
		
		# If database doesn't exist, create. Else update
		if(!File.exists?(dbfile))
			DataMapper.auto_migrate!
		elsif(File.exists?(dbfile))
			DataMapper.auto_upgrade!
		end
	
	end
	
end