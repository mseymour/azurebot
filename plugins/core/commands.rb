# -*- coding: UTF-8

# from https://github.com/telemachus/antinoos/blob/master/commands.rb
# Modifications by Azure/Mark Seymour.

class Commands
  include Cinch::Plugin

  plugin "commands"
  help "!c(ommands) - Get a list of defined commands to ask about"

  match /c(?:ommands)?/

  def execute(m)
    helpful = @bot.plugins.select do |plugin|
      plugin.class.instance_variable_get(:@__cinch_help_message)
    end

    helpful.collect! do |plugin|
      plugin.class.instance_variable_get(:@__cinch_name)
    end

    m.user.notice "Commands: #{helpful.join(', ')}"
  end
end