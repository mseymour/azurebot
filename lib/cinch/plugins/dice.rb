# -*- coding: utf-8 -*-

require_relative 'dice/boneroller'

module Cinch
  module Plugins
    class Dice
      include Cinch::Plugin

      set plugin_name: "Dicebox", help: "Dicebox -- Uses standard dice notation.\nUsage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)"

      match /^(.+)/, use_prefix: false
      def execute(m, s)
        return unless Boneroller.is_valid?(s)

        turn = Boneroller::Dice.new(s)
        turn.roll
        m.reply turn.to_s(true)
      
      rescue Boneroller::Errors::RollTooHighError => e
        m.reply "I don't have enough dice to roll that! Try something that is <= #{Boneroller::Dice::HIGH_ROLL_THRESHOLD}."
      rescue Boneroller::Errors::RollTooLowError => e
        m.reply "#{m.user.nick} is shooting the wind!"
      end
    end
  end
end
