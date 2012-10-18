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
      shared[:redis].scard("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase) == 0
    end

    def each_online_admin
      @bot.channels.each {|channel| channel.users.each { |user, _| yield(user) if is_admin?(user) } }
    end

    def each_online_trusted
      @bot.channels.each {|channel| channel.users.each { |user, _| yield(user) if is_trusted?(user) } }
    end

    private

    def add_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      shared[:redis].sadd("bot.%s:%s" % [@bot.irc.isupport['NETWORK'].downcase, type], mask)
    end
    
    def delete_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      shared[:redis].srem("bot.%s:%s" % [@bot.irc.isupport['NETWORK'].downcase, type], mask)
    end
    
    def get_action (type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      case type
      when :admins then shared[:redis].smembers("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase)
      when :trusted then shared[:redis].sunion("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase, "bot.%s:trusted" % @bot.irc.isupport['NETWORK'].downcase)
      end
    end

  end
end