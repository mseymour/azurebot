require 'singleton'
require 'digest/sha2'

class Admin
	include Singleton

	attr_reader :masks
	attr_accessor :password

	def initialize
		@masks = []
		@password = ""
	end

	def first_nick; @masks.first.match(/(.+)!(.+)@(.+)/)[1]; end;

	def logged_in? (mask); @masks.include?(mask.to_s); end;
	alias_method :is_admin?, :logged_in?

	def login! mask, password
		raise "A SHA256 password must be set via Admin#password." if @password.empty? || @password.size != 64 && @password.match(/[0-9a-f]/i)
		entered_password_hash = Digest::SHA2.new << password
		if @password === entered_password_hash.to_s
			@masks << mask.to_s
			true
		else
			false
		end
	end

	def logout! (mask); @masks.delete mask.to_s; end;

	def update (oldmask, newmask); @masks[@masks.index(oldmask.to_s)] = newmask.to_s; end;
end