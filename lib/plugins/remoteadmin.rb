require 'obj_ext/string'

module Plugins
  class RemoteAdmin
    include Cinch::Plugin

    set plugin_name: "Remote admin", help: "Relays certain messages to logged-in admins.", required_options: [:admins]

    listen_to :notice
    listen_to :private
    listen_to :ctcp
    def listen m, message = nil, target = nil
      return if m.ctcp? && m.ctcp_message.split[0].casecmp("action") == 0
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        next if m.user.nick.casecmp(admin.nick) == 0
        string = if m.ctcp?
          m.ctcp_message
        elsif !message.nil?
          message
        else
          m.message
        end
        admin.msg fmt_message(nick: m.user.nick, type: (m.ctcp? ? "CTCP" : m.command), string: string)
      }
    end

    listen_to :admin, method: :listen_hook
    listen_to :private_admin, method: :listen_hook
    def listen_hook m, message, target
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        next if m.user.nick.casecmp(admin.nick) == 0
        @bot.debug "Does the originating nick match an admin's nick? (Admin #{admin.nick}): #{m.user.nick.casecmp(admin.nick) == 0}"
        #admin.msg m.events.inspect
        #admin.msg fmt_message(nick: target.name, type: (!target.nil? ? target.name : m.command), string: (!message.nil? ? message : m.message))
        admin.msg fmt_message(nick: target.name, type: m.command, string: (!message.nil? ? message : m.message))
      }
    end

    listen_to :antispam, method: :listen_hook_antispam
    def listen_hook_antispam m, message, target
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        admin.msg fmt_message(nick: m.user.nick, type: (!target.nil? ? target.name : m.command), string: (!message.nil? ? message : m.message))
      }
    end

    def fmt_message params={}
      params = {
        nick: "?",
        type: "---",
        string: ""
      }.merge params
      "![b]%<type>s![b] [%<nick>s] %<string>s".irc_colorize % params
    end

  end
end