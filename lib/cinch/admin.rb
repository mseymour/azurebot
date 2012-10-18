module Cinch
  module Admin

    # Valid symbols for bot admin types
    TYPES = [:admins, :trusted]

    # @see #add_action
    # @example
    #   add_admin('*!*@unaffiliated/azure')
    def add_admin (mask); add_action(mask, :admins); end;
    # @see #delete_action
    # @example
    #   delete_admin('*!*@unaffiliated/azure')
    def delete_admin (mask); delete_action(mask, :admins); end;
    # @see #get_action
    def get_admins; get_action(:admins); end;
    
    # @see #add_admin
    def add_trusted (mask); add_action(mask, :trusted); end;
    # @see #delete_admin
    def delete_trusted (mask); delete_action(mask, :trusted); end;
    # @see #get_action
    def get_trusted; get_action(:trusted); end;


    # Fetches all stored hostmasks for the bot's per-network ADMIN group and performs a comparison between the supplied +User+ object and each hostmask.
    # @param [User] user A +User+ object.
    # @return [Boolean] True if the user is a bot Admin and authenticated, False if not.
    def is_admin? (user)
      get_admins.any? {|admin|
        !!(user =~ admin)
      } && user.authed?
    end

    # @see #is_admin?
    def is_trusted? (user)
      get_trusted.any? {|trusted|
        !!(user =~ trusted)
      } && user.authed?
    end

    # @return [Boolean] True if there are no hostmasks in the bot's per-network admin group.
    def no_admins?
      shared[:redis].scard("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase) == 0
    end

    # Yields all online users that are bot admins.
    # @yield [user] Users that are bot admins.
    def each_online_admin
      @bot.channels.flat_map {|channel| channel.users.keys }.uniq.each {|user| yield(user) if is_admin?(user) }
    end

    # @see #each_online_admin
    def each_online_trusted
      @bot.channels.flat_map {|channel| channel.users.keys }.uniq.each {|user| yield(user) if is_trusted?(user) }
    end

    private

    # Used for adding an admin or trusted used.
    # @param [String,Mask] mask A hostmask (for instance, `*!*@unaffiliated/azure`)
    # @param [Symbol] type A symbol of either +:admins+ or +:trusted+.
    # @example
    #  add_action('*!*@unaffiliated/azure', :admins)
    def add_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      shared[:redis].sadd("bot.%s:%s" % [@bot.irc.isupport['NETWORK'].downcase, type], mask)
    end
    
    # @see #add_action
    # @example
    #  delete_action('*!*@The.Stylish.Tyrant', :trusted)
    def delete_action (mask, type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      shared[:redis].srem("bot.%s:%s" % [@bot.irc.isupport['NETWORK'].downcase, type], mask)
    end
    
    # Gets all hostmasks related to a certain type.
    # @param [Symbol] type A symbol of either +:admins+ or +:trusted+.
    def get_action (type)
      raise ArgumentError, 'type must be either :admins or :trusted.' unless TYPES.include?(type)
      case type
      when :admins then shared[:redis].smembers("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase)
      when :trusted then shared[:redis].sunion("bot.%s:admins" % @bot.irc.isupport['NETWORK'].downcase, "bot.%s:trusted" % @bot.irc.isupport['NETWORK'].downcase)
      end
    end

  end
end