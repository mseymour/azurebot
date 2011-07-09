# -*- coding: UTF-8 -*-

require_relative '../../modules/bones-dice/dicebox'

class Dice
  include Cinch::Plugin
  plugin "dice"
  match /^(\d*#)?(\d+)d(\d+)/, use_prefix: false
  help "Dicebox -- uses standard dice notation. [X#]YdZ[(+|-)A]"

  def execute(m, multiplier, numdice, faces)
    
    # DICE HANDLER
    dice = Dicebox::Dice.new(m.message)
    begin
      d = dice.roll
      
      if (1..100).member?(numdice.to_i) && (1..100).member?(faces.to_i)
        m.reply(d, true)
      elsif numdice.to_i == 0 || faces.to_i == 0
        m.reply("#{m.user.nick} is shooting the wind!")
      else
        m.reply("I don't have enough dice to roll that!", true)
      end    
    
    rescue Exception => e
      bot.debug(e.to_s)
      m.reply("I don't understand...", true)
      
    end
  end
end