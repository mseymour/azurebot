# coding: utf-8
require 'time'
require 'chronic_duration'
require_relative '../helpers/check_user'

module Cinch
  module Plugins
    class Define
      include Cinch::Plugin
      
      set plugin_name: 'Definer', 
          react_on: :channel, 
          help: "Lets you... define things. Usage:\n* `!define <term> as <dfn>` -- Defines a term. Replaces an old one if it already exists.\n* `!whatis <term>` -- Looks up a term.\n* `!forget <term>` -- Forgets a term. (Chanops only)\n* `!reload definitions` `!save definitions` -- reloads/saves definitions from/to disk. (Chanops only)"
      
      def initialize(*args)
        super
        @redis = shared[:redis]
      end
      
      match /define (.+?) as (.+)/, method: :execute_define
      def execute_define(m, term, dfn)
        if !@redis.exists("term:"+term.downcase)
          @redis.hmset "term:#{term.downcase}", "term.case", term, "dfn", dfn, "edited.by", m.user.nick, "edited.time", Time.now
          m.reply "I now know that #{Format(:bold,term)} is \"#{dfn}\""
        else
          m.reply "That term already exists!"
        end
      end
    
      match /redefine (.+?) as (.+)/, method: :execute_redefine
      def execute_redefine(m, term, dfn)
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel, m.user)
        if @redis.exists("term:"+term.downcase)
          old_dfn = @redis.hgetall("term:"+term.downcase)
          edited = "(last edited by #{old_dfn["edited.by"]}, #{ChronicDuration.output(Time.now.utc.to_i - Time.parse(dfn["edited.time"]).to_i)} ago)"
          @redis.hmset "term:#{term.downcase}", "dfn", dfn, "edited.by", m.user.nick, "edited.time", Time.now.utc
          m.reply "The definition of #{Format(:bold,old_dfn['term.case'])} has been changed from \"#{old_dfn["dfn"]}\" to \"#{dfn}\". #{edited}"
        else
          m.reply "That term does not exist!"
        end
      #rescue
        #m.reply "#{Format(:red,:bold,"Uhoh!")} · #{$!}"
      end
    
      match /forget (.+)/, method: :execute_forget
      def execute_forget(m, term)
        return m.reply("You do not have the proper access! (not +qaoh)", true) unless check_user(m.channel, m.user)
        if @redis.exists("term:"+term.downcase)
          dfn = @redis.hgetall("term:"+term.downcase)
          edited = "(last edited by #{dfn["edited.by"]}, #{ChronicDuration.output(Time.now.utc.to_i - Time.parse(dfn["edited.time"]).to_i)} ago)"
          @redis.del("term:"+term.downcase)
          m.reply "I have forgotten #{Format(:bold,term)}. #{edited}"
        else
          m.reply "Sorry, but I do not know what #{Format(:bold,term)} is."
        end
      end
    
      match /^\?d (.+)/, method: :execute_whatis, use_prefix: false, group: :whatis
      match /whatis (.+)/, method: :execute_whatis, group: :whatis
      def execute_whatis(m, term)
        if @redis.exists("term:"+term.downcase)
          dfn = @redis.hgetall("term:"+term.downcase)
          term = dfn["term.case"] ? dfn["term.case"] : term
          m.reply "#{Format(:bold,term)} is: #{dfn["dfn"]} (last edited by #{dfn["edited.by"]}, #{ChronicDuration.output(Time.now.utc.to_i - Time.parse(dfn["edited.time"]).to_i)} ago)"
        else
          m.reply "Sorry, but I do not know what #{Format(:bold,term)} is."
        end
      end

    end
  end
end