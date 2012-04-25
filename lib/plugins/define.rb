# coding: utf-8
require 'ap'
require 'yaml'
YAML::ENGINE.yamler = 'psych'
require 'insensitive_hash'

module Plugins
  class Define
    include Cinch::Plugin
    
    attr :definitions
    
    set plugin_name: 'Definer', help: "Lets you... define things. Usage:\n* `!define <term> as <dfn>` -- Defines a term. Replaces an old one if it already exists.\n* `!whatis <term>` -- Looks up a term.\n* `!forget <term>` -- Forgets a term. (Chanops only)\n* `!reload definitions` `!save definitions` -- reloads/saves definitions from/to disk. (Chanops only)"
    
    def initialize *args
      super
      @definitions = YAML::load_file(config[:file]).insensitive
    end

    listen_to :connect, method: :on_connect
    def on_connect(m)
      Timer(3600) { # Every 30m
        @bot.loggers.debug "DEFINE -- Loading/Deserializing #{config[:file]}..."
        @definitions = YAML::load_file(config[:file]).insensitive
      }
    end

    listen_to :quit, method: :on_quit
    def on_quit(m)
      @bot.loggers.debug "DEFINE -- Serializing #{config[:file]} on quit..."
      File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
    end
    
    match /define (.+) as (.+)/, method: :execute_define
    def execute_define(m, term, dfn)
      begin
        if !@definitions.include?(term)
          @definitions[term] = dfn
          m.reply "I now know that #{Format(:bold,term)} is \"#{dfn}\""
          # Save to disk
          File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
        else
          m.reply "That term already exists!"
        end
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match /redefine (.+) as (.+)/, method: :execute_redefine
    def execute_redefine(m, term, dfn)
      begin
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel.users, m.user)
        if @definitions.include?(term)
          m.reply "The definition of #{Format(:bold,term)} has been changed from \"#{@definitions[term]}\" to \"#{dfn}\""
          @definitions[term] = dfn
          # Save to disk
          File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
        else
          m.reply "That term already exists!"
        end
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match /forget (.+)/, method: :execute_forget
    def execute_forget(m, term)
      begin
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel.users, m.user)
        @definitions.delete(term)
        m.reply "I have forgotten #{Format(:bold,term)}."
        File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match /^\?d (.+)/, method: :execute_whatis, use_prefix: false, group: :whatis
    match /whatis (.+)/, method: :execute_whatis, group: :whatis
    def execute_whatis(m, term)
      @definitions = YAML::load_file(config[:file]).insensitive
      if @definitions.include?(term)
        m.reply "#{Format(:bold,term)} is: #{@definitions[term]}"
      else
        m.reply "Sorry, but I do not know what #{Format(:bold,term)} is."
      end
    end
  
    match 'list terms', method: :execute_list
    def execute_list(m)
      @definitions = YAML::load_file(config[:file]).insensitive
      m.user.notice "These are all of the terms in alphabetical order:"
      # http://www.ruby-forum.com/topic/211339#918670
      listing = @definitions.keys.sort.group_by {|name| 
        case name[0]
        when /\d/ then '0'
        when /[^[:alpha:]]/ then '!'
        else 
          name[0].upcase
        end 
      }
      listing_arr = []
      listing.to_a.sort {|a,b| a[0].upcase<=>b[0].upcase }.each {|e| listing_arr << "#{Format(:bold,e[0].upcase)}: #{e[1].join(', ')}" }
      m.user.notice listing_arr.join('; ')
    end
  
    match 'reload definitions', method: :execute_reload
    def execute_reload(m)
      begin
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel.users, m.user)
        @definitions = YAML::load_file(config[:file]).insensitive
        m.reply "Definitions reloaded.", true
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    match 'save definitions', method: :execute_save
    def execute_save(m)
      begin
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel.users, m.user)
        File.open(config[:file], 'w') {|f| f.write(@definitions.to_yaml) }
        m.reply "Definitions saved to disk.", true
      rescue
        m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    end
  
    private
    
    def check_user(users, user)
      modes = @bot.irc.isupport["PREFIX"].keys
      modes.delete("v")
      modes.any? {|mode| users[user].include?(mode)}
    end
  end
end