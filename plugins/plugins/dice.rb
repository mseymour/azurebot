# -*- coding: UTF-8 -*-

require_relative 'dice/dicebox'

class Dice
  include Cinch::Plugin
  
  set(
    plugin_name: "Dicebox",
    help: "Dicebox -- Uses standard dice notation.\nUsage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)")

  match /^(\d*#)?(\d+)d(\d+)/, use_prefix: false
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