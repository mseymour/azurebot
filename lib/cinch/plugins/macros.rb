# coding: utf-8
require 'yaml'
require_relative "../admin"

module Cinch
  module Plugins
    class Macros
      include Cinch::Plugin
      include Cinch::Admin

      attr_reader :macros

      set plugin_name: "Macros", help: "Enables the classic #shakesoda macros to be used (including new ones.)", required_options: [:macro_yaml_path], react_on: :channel

      def initialize *args
        super
        @macros = YAML::load(open(config[:macro_yaml_path]))
      end

      match "reload macros", method: :execute_reloadmacros, react_on: :private, use_prefix: false
      def execute_reloadmacros m
        return unless is_trusted?(m.user)
        begin
          @macros = YAML::load(open(config[:macro_yaml_path]))
          m.user.notice "Macros have been reloaded."
        rescue
          m.user.notice "Reloading macros has failed: #{$!}"
        end
      end

      match /(\w+)(?: (.+))?/, method: :execute_macro, group: :macro
      def execute_macro m, macro, arguments
        return unless @macros.has_key?(macro)
        parse(arguments, @macros[macro], m.channel, m.user)
        
        # Guide to writing macros:
        # - A macro can be a string, hash, or array
        # - They can be embedded within each other (as lines, etc.)
        # To have options for a macro (either globally or within embedded macros:)
        # => macroname:
        # =>   type: (string) ['random'] (optional)
        # =>   sent_as: (string) ['reply','action'] (optional)
        # =>   sleep: (numeric) a number that represents how many seconds the bot will wait for each line
        # =>   lines: (array, string, hash) an object that represents the individual lines.

        # Guide to writing macros v3 templates:
        # transform/(default text)[template]
        # transform/ (optional):
        #   cap (all uppercase)
        #   lc (all lowercase)
        # (default text) (optional):
        #   Can be anything that you want. May want to watch usage of brackets &c.
        # [template] (required):
        #   Can be one of these tags:
        #   * in (input/argument, will default to the default text if available, otherwise it will choose a random nick.)
        #   * channel (the current channel that the command is run in.)
        #   * bot (The bot's nick)
        #   * self (the originating user's nick)
      end

      private

      # @param [String,NilClass] input The arguments for the command.
      # @param [String,Hash,Array] macro The macro object.
      # @param [Channel] channel The target channel.
      # @param [User] user The user that activated the macro.
      # @param [Hash] params The (optional) parameters for controlling the macro as set in the external resource.
      # @option params [String,NilClass] 'type' The type of output. Can be either nil, or "random"
      # @option params [String] 'sent_as' The method of sending the line. Can be either 'reply' or 'action'
      # @option params [Numeric,NilClass] 'sleep' How long does the bot wait to send the line?
      def parse(input, macro, channel, user, params={})
        params = { 'type' => nil, 'sent_as' => 'reply', 'sleep' => nil }.merge params

        if macro.respond_to? :has_key?
          lines = macro['lines']
          params = params.merge macro.reject {|k,_| k.eql? 'lines' }
          lines = lines.sample if params['type'].eql?('random') && lines.respond_to?(:each)
          parse(input, lines, channel, user, params)
        elsif macro.respond_to? :each
          macro.each {|line| parse(input, line, channel, user, params) }
        else
          sleep params['sleep'] if params['sleep']
          case params['sent_as']
          when 'action' then channel.action replace_tokens(input, macro.to_s, channel, user)
          else
            channel.msg replace_tokens(input, macro.to_s, channel, user)
          end
        end
      end

      # @see #parse (sans params)
      def replace_tokens(input, macro, channel, user)
        tokens = macro.scan(/((?:(\w+)\/)?(?:\((.+?)\))?(?:\[(\w+)\]))/)
        tokens.each_with_object(macro) {|(token,transform,default,template), memo|
          result = case template
          when 'in' then input || default || channel.users.keys.sample.nick
          when 'bot' then @bot.nick
          when 'channel' then channel.name
          when 'self' then user.nick
          else token
          end

          result = case transform
          when 'cap' then result.upcase
          when 'lc' then result.downcase
          else result
          end

          memo.sub!(token, result)
        }
      end

    end
  end
end