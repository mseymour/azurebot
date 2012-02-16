require_relative '../obj_ext/string'

module Plugins
  class RemoteAdmin
    include Cinch::Plugin

    set plugin_name: "Remote admin", help: "Relays certain messages to logged-in admins.", required_options: [:admins]

    listen_to :private, method: :listen_private
    def listen_private(m, message = nil, target = nil)
      return if m.command == "NOTICE" || m.ctcp?
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        next if m.user == admin
        string = if !message.nil?
          message
        else
          m.message
        end
        admin.msg fmt_message(nick: m.user.nick, type: "PRIVMSG", string: string)
      }
    end

    listen_to :notice, method: :listen_notice
    def listen_notice(m, message = nil, target = nil)
      return if m.command == "PRIVMSG" && m.ctcp?
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        next if m.user == admin
        string = if !message.nil?
          message
        else
          m.message
        end
        admin.msg fmt_message(nick: m.user.nick, type: "NOTICE", string: string)
      }
    end

    listen_to :ctcp, method: :listen_ctcp
    def listen_ctcp(m, message = nil, target = nil)
      return if m.command == "NOTICE" || m.ctcp_message.split[0].casecmp("action") == 0
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        #next if m.user.nick.casecmp(admin.nick) == 0
        string = m.ctcp_message
        admin.msg fmt_message(nick: m.user.nick, type: "CTCP", string: string)
      }
    end

    listen_to :admin, method: :listen_hook
    listen_to :private_admin, method: :listen_hook
    def listen_hook(m, message, target)
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        next if m.user == admin
        @bot.debug "Does the originating nick match an admin's nick? (Admin #{admin.nick}): #{m.user == admin}"
        #admin.msg m.events.inspect
        #admin.msg fmt_message(nick: target.name, type: (!target.nil? ? target.name : m.command), string: (!message.nil? ? message : m.message))
        admin.msg fmt_message(nick: target.name, type: m.command, string: (!message.nil? ? message : m.message))
      }
    end

    listen_to :antispam, method: :listen_hook_antispam
    def listen_hook_antispam(m, message, target)
      config[:admins].each_admin {|nick, username, host|
        admin = User(nick)
        admin.msg fmt_message(nick: m.user.nick, type: (!target.nil? ? target.name : m.command), string: (!message.nil? ? message : m.message))
      }
    end

    def fmt_message(params={})
      params = {
        nick: "?",
        type: "---",
        string: ""
      }.merge params
      "#{Format(:bold, "%<type>s")} [%<nick>s] %<string>s" % params
    end

  end
end
