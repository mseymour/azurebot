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

  def first_nick; !@masks.empty? ? @masks.first.match(/(.+)!(.+)@(.+)/)[1] : nil; end;

  def logged_in? (mask); @masks.include?(mask.to_s); end;
  alias_method :is_admin?, :logged_in?

  def login! mask, password
    raise "A SHA256 password must be set via Admin#password." if @password.empty? || @password.size != 64 && @password.match(/[0-9a-f]/i)
    entered_password_hash = Digest::SHA2.new << password
    @masks << mask.to_s if @password === entered_password_hash.to_s
  end

  def logout! (mask); @masks.delete mask.to_s; end;

  def update (oldmask, newmask); @masks[@masks.index(oldmask.to_s)] = newmask.to_s; end;

  def each_admin &block
    @masks.each {|e|
      elements = e.match(/(.+)!(.+)@(.+)/)
      case block.arity
      when 1
        yield e # mask
      when 3
        yield elements[1], elements[2], elements[3] # nick, username, host
      end
    }
  end
end