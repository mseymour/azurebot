module Plugins
  class RussianRoulette
    include Cinch::Plugin

    set plugin_name: "Russian Roulette", help: "In Soviet Russia, boolet shoots YOU!\nUsage: !rr <nick>", react_on: :channel

    def initialize *args
      super
      @@phrases = [
        "\"BANG\" You're dead! ... Just kidding comrade... for now.",
        "\"...BLAMMO!\" (hangfires are a bitch, aren't they?)",
        "Are you scared yet, comrade?",
        "Are you pissing your pants yet?",
        "You are lucky, comrade. At least for now.",
        "The chamber was as empty as your head.",
        "Damn. And I thought that it had bullet too.",
        "Lucky you, comrade.",
        "Must be your lucky day, comrade.",
        "\"BLAM!\" you can't play russian roulette with a tokarev, comrade.",
        "... Looks like you get to live another day... or 5 second.",
        "... Bad primer."
      ]
    end

    def check_user(users, user)
      ["h", "o", "a", "q"].any? {|mode| users[user].include?(mode)}
    end

    match /rr(?:\s(.+))?/
    def execute m, nick
      #return if disabled?
      return m.reply("I am sorry comrade, but I do not have pistol on me.") unless check_user(m.channel.users, User(@bot.nick))
      nick = (check_user(m.channel.users, m.user) && !!nick && nick.valid_nick? && !User(nick).unknown? && nick.casecmp(@bot.nick) != 0 ? nick : m.user.nick);

      turn_count = Random.new.rand(1..6)
      round = Random.new.rand(1..6)
      phrases = @@phrases.dup

      @bot.loggers.debug "turn count: #{turn_count}"
      @bot.loggers.debug "round: #{round}"
      @bot.loggers.debug "turn_count(#{turn_count}) < round(#{round}): #{turn_count < round}"

      m.channel.action "starts a #{turn_count}-turn game of Russian Roulette with #{nick}."
      sleep 5

      turn_count.times do |chamber|
        @bot.loggers.debug "Chamber #{chamber.succ}/#{turn_count}"
        if round != chamber.succ
          @bot.loggers.debug "round(#{round}) != chamber(#{chamber.succ})"
          phrase = phrases.sample
          phrases.delete phrase
          m.reply "*click* #{phrase}"
        else
          @bot.loggers.debug "round(#{round}) == chamber(#{chamber.succ})?"
          m.reply "*click*"
          m.channel.kick(User(nick), "*BLAM*")
          m.channel.action "watches #{nick}'s brain splatter across the wall."
          break
        end
        sleep 5
      end

      m.reply "Looks like you get to live another day." if turn_count < round
      sleep 1 if turn_count < round
      m.channel.action "holsters the pistol."

    end

  end
end