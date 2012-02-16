require 'date'
require 'redis'

module Plugins
  class TimeBan
    def initialize
      super
      @redis = Redis.new
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

    match /timeban (\W) (\W) (.+)/
    def execute m, nick, range, reason
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
        "when.banned": Time.now, 
        "when.unbanned": unbantime, 
        "banned.by": m.user.nick, 
        "ban.reason": reason }
      
      # schema: timeban:channel:nick (ex: timeban:#shakesoda:kp_centi)
      @redis.hmset "timeban:#{m.channel.name}:#{nick}", *fields.flatten
      #@redis.hgetall "timeban:#{m.channel.name}:#{nick}"
      #@redis.del "timeban:#{m.channel.name}:#{nick}"

    end

  end
end