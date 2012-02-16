require 'date'
require 'redis'

module Plugins
  class TimeBan
    include Cinch::Plugin

    def initialize *args
      super
      @redis = Redis.new
    end

    listen_to :join, method: :on_join
    def on_join m
      return unless m.user == @bot
      # Get all timeban keys for #channel:
      timebans = @redis.keys "timeban:#{m.channel.name}:*"
      timebans.each {|k|
        v = @redis.hgetall k
        @bot.loggers.debug "TIMEBAN: Loading timed ban from Redis: #{v.inspect}"
        channel, nick = *k.match(/(.+):(.+):(.+)/)[2..3]
        if Time.now < Time.parse(v["when.unbanned"])
          @bot.loggers.debug "TIMEBAN: Seconds until unban: #{Time.parse(v["when.unbanned"]) - Time.now}"
          timer(Time.parse(v["when.unbanned"]) - Time.now, shots: 1) { 
            unban(channel, nick, v)
          }
        else # If the timeban already expired, unban on connect.
          unban(channel, nick, v)
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

    match /timeban (\S*) ((?:\d+[yMwdhms])+) (.+)/
    def execute m, nick, range, reason
      @bot.loggers.debug "TIMEBAN: nick: #{nick}; range: #{range}; reason: #{reason}"
      return unless check_user(m.channel.users, m.user)
      @bot.loggers.debug "Passed user privs check"
      return m.user.notice "I cannot kickban #{nick} because I do not have the correct privileges." unless check_user(m.channel.users, User(@bot.nick))
      @bot.loggers.debug "Passed bot privs check"

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
      unbantime = Time.now + delta

      fields = {
        "when.banned" => Time.now, 
        "when.unbanned" => unbantime, 
        "banned.by" => m.user.nick, 
        "ban.reason" => reason,
        "ban.host" => User(nick).mask("*!*@%h") }
    
      
      @bot.loggers.debug "TIMEBAN: HMSET \"timeban:#{m.channel.name}:#{nick}\": #{fields.inspect}"
      # schema: timeban:channel:nick (ex: timeban:#shakesoda:kp_centi)
      @redis.hmset "timeban:#{m.channel.name}:#{nick}", *fields.flatten

      # KICKBAN HIM!
      m.channel.ban(fields["ban.host"]);
      m.channel.kick(nick, "#{fields["banned.by"]} has banned you until #{Time.at(fields["when.unbanned"]).strftime("%A, %B %-d, %Y at %-l:%M %P")}, because \"#{fields["ban.reason"]}\".");
      @bot.loggers.debug "TIMEBAN: Kickbanned #{nick} from #{m.channel.name}: #{fields.inspect}"

      @bot.loggers.debug "TIMEBAN: Seconds until unban: #{Time.at(fields["when.unbanned"]) - Time.now}"
      timer(Time.at(fields["when.unbanned"]) - Time.now, shots: 1) { 
        unban(m.channel.name, nick, fields)
      }

    end

    private

    def check_user(users, user)
      modes = @bot.irc.isupport["PREFIX"].keys
      modes.delete("v")
      modes.any? {|mode| users[user].include?(mode)}
    end

    def unban channel, nick, v
      chan = Channel(channel)
      is_in_channel = @bot.channels.include?(chan.name)
      chan.join if !is_in_channel # To do the unbanning if not in the channel
      chan.unban(v["ban.host"])
      #chan.part if !is_in_channel  # Part if was not in the channel
      @redis.del "timeban:#{chan.name}:#{nick}"
      @bot.loggers.debug "TIMEBAN: #{nick} has been unbanned from #{channel}. Banned by: #{v["banned.by"]}; Ban reason: #{v["ban.reason"]}"
    end

  end
end