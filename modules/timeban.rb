require 'active_support/core_ext'
require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'time'

module Timebans
		class Ban
			include DataMapper::Resource
			property :id, Serial
			property :channel, String
			property :hostname, String
			property :datebanned, DateTime
			property :dateunbanned, DateTime
			property :reason, String
			property :bannedby, String
		end 
		DataMapper.finalize
		
		def Timebans.unbanned?
			b = Ban.all
			hostnames_to_unban = Hash.new
			b.each {|e| 
				break if e.dateunbanned.blank? # Infinite ban.
				if e.dateunbanned < Time.now
					hostnames_to_unban.store(e.channel, e.hostname)
				end
			}
			hostnames_to_unban
		end
	
		def Timebans.remove_ban! channel, mask
			the_ban = Ban.first( :channel => channel, :hostname => mask )
			the_ban.destroy
		end

end