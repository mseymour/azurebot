require 'date'
require 'redis'
require_relative '../modules/helpers/table_format'
require_relative '../modules/stringhelpers'

module Plugins
  class TimeBan
    include Cinch::Plugin
    include StringHelpers

    set plugin_name: "Timeban", react_on: :channel

    def initialize(*args)
      super
      @redis = Redis.new
    end

    listen_to :join, method: :on_join
    def on_join(m)
      return unless m.user == @bot
      # Get all timeban keys for #channel:
      timebans = @redis.keys "timeban:#{m.channel.name}:*"
      timebans.each {|k|
        v = @redis.hgetall k
        @bot.loggers.debug "TIMEBAN: Loading timed ban for #{k.split(":")[-1]} from Redis: #{v.inspect}"
        channel, nick = *k.match(/(.+):(.+):(.+)/)[2..3]
        if Time.now < Time.parse(v["when.unbanned"])
          @bot.loggers.debug "TIMEBAN: Seconds until unban: #{Time.parse(v["when.unbanned"]) - Time.now}"
          timer(Time.parse(v["when.unbanned"]) - Time.now, shots: 1) {
            unban(channel, nick)
          }
        else # If the timeban already expired, unban on connect.
          unban(channel, nick)
        end
      }
    end

    def calculate_delta(params={})
      params = {
        years: 0, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0
      }.merge params

      today = Date.today
      date = today
      date = date >> (params[:years] * 12) if params[:years] != 0
      date = date >> params[:months] if params[:months] != 0
      date = date + params[:days] if params[:days] != 0

      day_delta = (date - today).to_i

      (params[:weeks] * 604800) + (day_delta * 86400) + (params[:hours] * 3600) + (params[:minutes] * 60) + params[:seconds]
    end

    match /timeban (\S*) ((?:\d+[yMwdhms])+)\s?(.+)?/
    def execute(m, nick, range, reason)
      return unless check_user(m.channel.users, m.user)
      return m.user.notice "I cannot kickban #{nick} because I do not have the correct privileges." unless check_user(m.channel.users, User(@bot.nick))
      return if User(nick) == @bot # refuse to kickban the bot
      return if User(nick).unknown? # refuse to ban a user that does not exist

      @bot.loggers.debug "TIMEBAN: nick: #{nick}; range: #{range}; reason: #{reason}"

      reason ||= "fuck you!"

      units = {
        'y' => :years,
        'M' => :months,
        'w' => :weeks,
        'd' => :days,
        'h' => :hours,
        'm' => :minutes,
        's' => :seconds
      }

      pattern = /(\d+)([yMwdhms])/

      values = Hash[range.scan(pattern).map{|v,k| [units[k],Integer(v)] }]
      delta = calculate_delta(values)
      bantime = Time.now
      unbantime = Time.now + delta

      fields = {
        "when.banned" => bantime,
        "when.unbanned" => unbantime,
        "banned.by" => m.user.nick,
        "ban.reason" => reason,
        "ban.host" => User(nick).mask("*!*@%h") }


      @bot.loggers.debug "TIMEBAN: HMSET \"timeban:#{m.channel.name}:#{nick}\": #{fields.inspect}"
      # schema: timeban:channel:nick (ex: timeban:#shakesoda:kp_centi)
      @redis.hmset "timeban:#{m.channel.name.downcase}:#{nick.downcase}", *fields.flatten

      # KICKBAN HIM!
      m.channel.ban(fields["ban.host"]);
      m.channel.kick(nick, "Banned for #{time_diff_in_natural_language(Time.now, fields["when.unbanned"], acro: false)} by #{m.user.nick} (#{fields["ban.reason"]})");
      @bot.loggers.debug "TIMEBAN: Kickbanned #{nick} from #{m.channel.name}: #{fields.inspect}"

      @bot.loggers.debug "TIMEBAN: Seconds until unban: #{Time.at(fields["when.unbanned"]) - Time.now}"
      timer(Time.at(fields["when.unbanned"]) - Time.now, shots: 1) {
        unban(m.channel.name, nick)
      }

    end

    match /unban (\S*)/, method: :execute_unban
    def execute_unban(m, nick)
      return unless check_user(m.channel.users, m.user)
      return m.user.notice "I cannot unban #{nick} because I do not have the correct privileges." unless check_user(m.channel.users, User(@bot.nick))
      return m.user.notice "I cannot find the timeban entry \"timeban:#{m.channel.name.downcase}:#{nick.downcase}\"." if @redis.hgetall("timeban:#{m.channel.name.downcase}:#{nick.downcase}").empty? # Refuse to unban if entry does not exist
      unban(m.channel.name, nick)
    end

    match "listbans",  method: :execute_listbans
    def execute_listbans(m)
      return unless check_user(m.channel.users, m.user)
      list = []
      
      timebans = @redis.keys "timeban:#{m.channel.name}:*"
      timebans.each {|k|
        v = @redis.hgetall k
        list << [k.split(":")[-1], Time.parse(v["when.banned"]).strftime("%Y-%m-%d %I:%M:%S %p %Z"), v["banned.by"], v["ban.reason"], v["ban.host"], time_diff_in_natural_language(Time.now, v["when.unbanned"], acro: true)]
      }

      ban_table = Helpers::table_format(list,
        headers: ["nick","banned", "by", "reason", "host", "unbanned"],
        gutter: 2,
        display_eot: false,)

      m.user.notice "List of all bans in place for #{m.channel.name}:\n#{ban_table}"
    end

    private

    def check_user(users, user)
      modes = @bot.irc.isupport["PREFIX"].keys
      modes.delete("v")
      modes.any? {|mode| users[user].include?(mode)}
    end

    def unban(channel, nick)
      chan = Channel(channel)
      is_in_channel = @bot.channels.include?(chan.name)
      fields = @redis.hgetall "timeban:#{chan.name.downcase}:#{nick.downcase}"
      chan.join if !is_in_channel # To do the unbanning if not in the channel
      sleep 5 if !is_in_channel # avoiding a possible race condition where the bot is not opped immediately on join
      chan.unban(fields["ban.host"])
      #chan.part if !is_in_channel  # Part if was not in the channel
      @redis.del "timeban:#{chan.name.downcase}:#{nick.downcase}"
      @bot.loggers.debug "TIMEBAN: #{nick} has been unbanned from #{channel}. Banned by: #{fields["banned.by"]}; Ban reason: #{fields["ban.reason"]}"
    end
  end
end