# -*- coding: utf-8 -*-

class Float
  def prettify
    to_i == self ? to_i : self
  end
end

module Cinch
  module Plugins
    class Decide
      include Cinch::Plugin
      set(
        plugin_name: "Decider",
        help: "Helps you decide on things.\nUsage: `!decide [a list of items separated by \", \", \", or\", or \" or \"]`; Usage: `!coin`; Usage: `!rand [x] [y]`")

      def decide!(list)
        list = list.gsub(/\x03([0-9]{2}(,[0-9]{2})?)?/,"") #strips IRC colors
        options = list.gsub(/ or /i, ",").split(",").map(&:strip).reject(&:empty?)
        options[Random.new.rand(1..options.length)-1]
      end

      match /decide (.+)/, method: :execute_decision
      match /choose (.+)/, method: :execute_decision
      def execute_decision(m, list)
        m.safe_reply("I choose \"#{decide! list}\"!",true);
      end

      match "coin", method: :execute_coinflip
      def execute_coinflip(m)
        face = Random.new.rand(1..2) == 1 ? "heads" : "tails";
        m.safe_reply("I choose \"#{face}\"!",true);
      end

      valid_number = /(?:-|\+)?\d*\.?\d+(?:e)?(?:-|\+)?\d*\.?\d*/
      match /rand (#{valid_number}) (#{valid_number})/, method: :execute_random
      def execute_random(m, x, y)
        x = x.to_f.prettify
        y = y.to_f.prettify
        xy = "(x=#{x}, y=#{y})"
        return m.reply("X must not be equal to Y. #{xy}", true) if x == y
        return m.reply("X must be lesser than Y. #{xy}") if x > y

        m.reply "Your number is: #{Random.new.rand(x..y)}.", true
      end

      match /token (\d+)/, method: :execute_token
      def execute_token(m, length)
        max_length = 256
        def power_of_2?(number)
          (1..32).each { |bit| return true if number == (1 << bit) }
          false
        end

        return m.reply "Your token length can only be 2, 4, 8, 16, 32, 64, 128, and 256." unless power_of_2?(length.to_i)
        return m.reply "Your token length must be 256 or below." if length.to_i > 256
        characters = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
        key = (0..length.to_i-1).map{characters.sample}.join
        m.reply "Your token is: #{key}", true
        m.user.notice "Alternatively, you may want it in these formats: #{key.scan(/.{0,#{key.length / (key.length / 8)}}/).reject(&:empty?).join("-")}, #{key.upcase.scan(/.{0,#{key.length / (key.length / 8)}}/).reject(&:empty?).join("-")}"
      end

    end
  end
end
