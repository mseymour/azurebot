module Cinch
  module Admin

    TYPES = [:admins, :trusted]

    def add_admin (mask); add_action(mask, :admins); end;
    def delete_admin (mask); delete_action(mask, :admins); end;
    def get_admins; get_action(:admins); end;
    
    def add_trusted (mask); add_action(mask, :trusted); end;
    def delete_trusted (mask); delete_action(mask, :trusted); end;
    def get_trusted; get_action(:trusted); end;


    def is_admin? (user)
      get_admins.any? {|admin|
        !!(user =~ admin)
      } && user.authed?
    end

    def is_trusted? (user)
      get_trusted.any? {|trusted|
        !!(user =~ trusted)
      } && user.authed?
    end

    def no_admins?
      network = @bot.irc.isupport['NETWORK']
      shared[:redis].scard("bot.#{network.downcase}:admins") == 0
    end

    def each_online_admin(&blk)
      u = @bot.channels.inject([]) {|memo, chan| memo | chan.users.keys }
      u.each {|user|
        next if !is_admin?(user)
        yield user
      }
    end

    def each_online_trusted(&blk)
      u = @bot.channels.inject([]) {|memo, chan| memo | chan.users.keys }
      u.each {|user|
        next if !is_trusted?(user)
        yield user
      }
    end

    private

    def add_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      network = @bot.irc.isupport['NETWORK']
      shared[:redis].sadd "bot.#{network.downcase}:#{type}", mask
    end
    
    def delete_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      network = @bot.irc.isupport['NETWORK']
      shared[:redis].srem "bot.#{network.downcase}:#{type}", mask
    end
    
    def get_action (type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      network = @bot.irc.isupport['NETWORK']
      case type
      when :admins then shared[:redis].smembers "bot.#{network.downcase}:admins"
      when :trusted then shared[:redis].sunion "bot.#{network.downcase}:admins", "bot.#{network.downcase}:trusted"
      end
    end

  end
end