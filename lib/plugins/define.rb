# coding: utf-8
require 'ap'
require 'yaml'
YAML::ENGINE.yamler = 'psych'
require 'insensitive_hash'

module Plugins
  class Define
    include Cinch::Plugin
    
    attr :definitions
    
    set plugin_name: 'Definer', help: 'Lets you... define things. Usage:\n* `!define <term> as <dfn>` -- Defines a term. Replaces an old one if it already exists.\n* `!whatis <term>` -- Looks up a term.\n* `!forget <term>` -- Forgets a term. (Chanops only)\n* `!reload definitions` `!save definitions` -- reloads/saves definitions from/to disk. (Chanops only)'
    
    def initialize *args
      super
      @definitions = YAML::load_file(config[:file]).insensitive
    end
    
    match /define (.+) as (.+)/, method: :execute_define
    def execute_define(m, term, dfn)
      begin
        m.reply "The previous definition of #{term} was #{@definitions[term]}." if @definitions.include?(term)
        @definitions[term] = dfn
        m.reply "I now know that #{Format(:bold,term)} is #{Format(:bold,dfn)}#{dfn[-1] !~ /\W$/ ? "." : ""}"
        # Save to disk
        File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match /forget (.+)/, method: :execute_forget
    def execute_forget(m, term)
      begin
        m.reply "I have forgotten #{Format(:bold,term)}."
        File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match /whatis (.+)/, method: :execute_whatis
    def execute_whatis(m, term)
      if @definitions.include?(term)
        m.reply "#{Format(:bold,term)} is: \"#{@definitions[term]}\""
      else
        m.reply "Sorry, but I do not know what #{Format(:bold,term)} is."
      end
    end
  
    match 'reload definitions', method: :execute_reload
    def execute_reload m
      return unless check_user(m.channel.users, m.user)
      @definitions = YAML::load_file(config[:file]).insensitive
    end
  
    match 'save definitions', method: :execute_save
    def execute_save m
      return unless check_user(m.channel.users, m.user)
      File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
    end
  
    private
    
    def check_user(users, user)
      modes = @bot.irc.isupport["PREFIX"].keys
      modes.delete("v")
      modes.any? {|mode| users[user].include?(mode)}
    end
  end
end