require 'time'

class ATest
	include Cinch::Plugin
	$order = []
	$order << "Initialized global variable $order. <ts:#{Time.now.to_i}>"
	match "testme"
	$order << "match 'testme'. <ts:#{Time.now.to_i}>"
	
	def initialize *args
		$order << "Initializing ATest, before calling 'Super'. <ts:#{Time.now.to_i}>"
		super
		@@ts = []
		@@ts << Time.now.to_i
		$order << "Initialized ATest, after calling 'Super'. <ts:#{Time.now.to_i}>"
	end
	
	def listen m
		$order << "Match '!testme' heard. <ts:#{Time.now.to_i}>"
		m.reply "$order:" + $order.join("; ")
		m.reply "@@ts:" + @@ts.join("; ")
	end
end