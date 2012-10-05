require_relative "../helpers/check_user"

module Cinch
  module Plugins
    class RussianRoulette
      include Cinch::Plugin

      set plugin_name: "Russian Roulette", help: "In Soviet Russia, boolet shoots YOU!\nUsage: !rr <nick>", react_on: :channel

      attr_reader :games

      def initialize(*args)
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
        @games = []
      end

      match /rr(?: (.+))?/, group: :x_rr
      def execute(m, nick = nil)
        #return if disabled?
        return m.reply("I am sorry comrade, but I do not have pistol on me.") unless check_user(m.channel, @bot)
        return m.user.notice "Sorry, but there is already a game going on." if @games.include?(m.channel.name)
        @games << m.channel.name

        nick ||= m.user.nick
        target = User(nick)
        target = m.user if target == @bot || !check_user(m.channel, m.user) || target.unknown?

        turn_count = Random.new.rand(1..6)
        round = Random.new.rand(1..6)
        phrases = @@phrases.dup

        #@bot.loggers.debug "turn count: #{turn_count}"
        #@bot.loggers.debug "round: #{round}"
        #@bot.loggers.debug "turn_count(#{turn_count}) < round(#{round}): #{turn_count < round}"

        m.channel.action "starts a #{turn_count}-turn game of Russian Roulette with #{target.nick}."
        sleep 5

        turn_count.times do |chamber|
          if !m.channel.users.include?(target)
            @games.delete(m.channel.name) #game cancelled
            m.reply "Oh vell, it vas fun while it lasted."
            m.channel.action "holsters the pistol."
            return
          end

          #@bot.loggers.debug "Chamber #{chamber.succ}/#{turn_count}"
          if round != chamber.succ
            #@bot.loggers.debug "round(#{round}) != chamber(#{chamber.succ})"
            phrase = phrases.sample
            phrases.delete phrase
            m.reply "*click* #{phrase}"
          else
            #@bot.loggers.debug "round(#{round}) == chamber(#{chamber.succ})?"
            m.reply "*click*"
            m.channel.kick(target, "*BLAM*")
            m.channel.action "watches #{nick}'s brain splatter across the wall."
            break
          end
          sleep 5
        end

        m.reply "Looks like you get to live another day." if turn_count < round
        sleep 1 if turn_count < round
        m.channel.action "holsters the pistol."
        @games.delete(m.channel.name) #game done

      end

    end
  end
end