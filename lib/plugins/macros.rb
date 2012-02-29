# coding: utf-8
require 'yaml'

module Plugins
  class Macros
    include Cinch::Plugin

    attr_reader :macros

    set plugin_name: "Macros", help: "Enables the classic #shakesoda macros to be used (including new ones.)", required_options: [:macro_yaml_path], react_on: :channel

    def initialize *args
      super
      @macros = YAML::load(open(config[:macro_yaml_path]))
    end

    match "reloadmacros", method: :execute_reloadmacros
    def execute_reloadmacros m
      return unless check_user(m.channel.users, m.user)
      begin
        @macros = YAML::load(open(config[:macro_yaml_path]))
        m.user.notice "Macros have been reloaded."
      rescue
        m.user.notice "Reloading macros has failed: #{$!}"
      end
    end

    match /(\w+) ?(.+)?/, method: :execute_macro
    def execute_macro m, macro, arguments

      selection = @macros[macro]

      arguments.gsub!(/^\W+/,'') if arguments # preventing the bot from potentially running op-only commands.

      replace = lambda {|string|
        output = string.dup
        output.gsub!(/<(.*?)>/) {|t| 
          v = t[1..-2].split(',')
          v[0] == 'in' ? (v[1].nil? ? (arguments ? arguments : v[1]) : v[1]) : v.join(',')
          if v[0] == 'in'
            if !arguments.nil?
              arguments
            else
              v[1].nil? ? m.user.nick : v[1]
            end
          else
            v.join(",")
          end
        }
        return output.gsub(/\^(.*?)\^/){|m| m[1..-2].upcase }.gsub(/v(.*?)v/){|m| m[1..-2].downcase}
      } 

      lines = lambda {|obj| 
        if obj.is_a? Hash
          sleep obj["seconds"] if !!obj["seconds"]
          if obj["type"] == "action"
            m.channel.action replace.call(obj["msg"].to_s)
          else
            m.channel.msg replace.call(obj["msg"].to_s)
          end
        elsif obj.is_a? Array
          m.channel.msg replace.call(obj.flatten.join(", "))
        else
          m.channel.msg replace.call(obj.to_s)
        end
      }

      if selection.is_a? Hash
        case selection["type"]
        when "random"
          lines.call selection["lines"].sample
        else
          lines.call selection["lines"]
        end
      elsif selection.is_a? Array
        selection.each {|e| lines.call e}
      else
        m.channel.msg replace.call(selection.to_s)
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