require_relative "../helpers/check_user"

module Cinch
  module Plugins
    class RussianRoulette
      include Cinch::Plugin

      set plugin_name: "Russian Roulette", help: "In Soviet Russia, boolet shoots YOU!\nUsage: !rr <nick>", react_on: :channel

      attr_reader :games

      PHRASES = [
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

      def initialize(*args)
        super
        @games = []
      end

      match /rr(?: (.+))?/
      def execute(m, nick)
        return m.reply "I am sorry comrade, but I do not have pistol on me." unless check_user(m.channel, @bot)
        return m.user.notice "Sorry comrade, but there is already game going on." if @games.include?(m.channel.name)
        
        # player setup
        player = check_user(m.channel, m.user) ? User(nick || m.user) : m.user
        player = m.user if player == @bot
        # be nice, don't force the game on the starter unless the user actually exists in the channel.
        return m.reply "I am terribly sorry %s, but I don't know %s." % [m.user.nick, player.nick] unless m.channel.users.include?(player)
        
        # start game
        @games << m.channel.name
        
        turns, round_location = Array.new(2) {|i| Random.new.rand(1..6) }
        m.channel.action "starts a %d-turn game of Russian Roulette with %s." % [turns, player.nick]
        
        phrases = PHRASES.dup.shuffle

        sleep 5

        turns.times do |chamber|
          return end_game(m.channel, true) if !m.channel.users.include?(player)
          if round_location == chamber.succ
            m.reply "*click*"
            m.channel.ban(player.mask('*!*@%h'))
            Timer(15, shots: 1) { m.channel.unban(player.mask('*!*@%h')) }
            m.channel.kick(player, "*BLAM*")
            m.channel.action "watches %s's brain splatter across the wall." % player.nick
            break
          else
            phrase = phrases.pop
            m.reply "*click* %s" % phrase
          end
          sleep 5
        end

        m.reply "Looks like you get to live another day." if turns < round_location
        sleep 1 if turns < round_location
        end_game(m.channel)
      end

      private

      def end_game(channel, premature=false)
        @games.delete channel.name
        channel.msg "Oh vell, it vas fun vhile it lasted." if premature
        channel.action "holsters the pistol."
      end
    end
  end
end