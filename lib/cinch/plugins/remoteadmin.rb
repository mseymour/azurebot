require_relative '../admin'

module Cinch
  module Plugins
    class RemoteAdmin
      include Cinch::Plugin
      include Cinch::Admin

      set plugin_name: "Remote admin", help: "Relays certain messages to logged-in admins."

      listen_to :private, method: :listen_private
      def listen_private(m, message = nil, target = nil)
        return if m.ctcp? || m.events.include?(:notice)
        each_online_admin {|admin|
          admin.notice prettify(nick: m.user.nick, source: m.target.name, type: m.command, string: m.message)
        }
      end

      listen_to :notice, method: :listen_notice
      def listen_notice(m, message = nil, target = nil)
        return if m.ctcp? || !m.user
        if m.user.nick =~ /^.+serv$|^global$/i
          each_online_admin {|admin|
            admin.notice prettify(nick: m.user.nick, source: m.target.name, type: m.command, string: m.message)
          }
        else
          each_controlchannel {|channel|
            channel.msg prettify(nick: m.user.nick, source: m.target.name, type: m.command, string: m.message)
          }
        end
      end

      listen_to :ctcp, method: :listen_ctcp
      def listen_ctcp(m, message = nil, target = nil)
        return if !m.ctcp? || m.action?
        return if m.ctcp_command.eql?('PING')
        if m.user.nick =~ /^.+serv$/i
          each_online_admin {|admin|
            admin.notice prettify(nick: m.user.nick, source: m.target.name, type: "CTCP", string: m.ctcp_message)
          }
        else
          each_controlchannel {|channel|
            channel.msg prettify(nick: m.user.nick, source: m.target.name, type: "CTCP", string: m.ctcp_message)
          }
        end
      end

      listen_to :admin, method: :listen_hook
      def listen_hook(m, message, target)
        each_controlchannel {|channel|
          channel.msg prettify(nick: m.user.nick, source: m.target.name, type: "ADMIN", string: message)
        }
      end

      listen_to :private_admin, method: :private_listen_hook
      def private_listen_hook(m, message, target)
        each_online_admin {|admin|
          admin.notice prettify(nick: m.user.nick, source: m.target.name, type: "P.ADMIN", string: message)
        }
      end

      # listen_to :antispam, method: :listen_hook_antispam
      # def listen_hook_antispam(m, message, target)
      #   Channel(shared[:controlchannel]).msg prettify(nick: m.user.nick, source: m.target.name, type: "ANTISPAM", string: "#{message.first} | kick count: #{message.last.kick_count}; first offence: #{(Time.now - message.last.current.first_offence).round(4)}s; last offence: #{(Time.now - message.last.current.last_offence).round(4)}s; count: #{message.last.current.count}")
      # end

      private

      def prettify(params={})
        params = {
          nick: "?",
          source: "?",
          type: "---",
          string: ""
        }.merge params
        if params[:nick].eql?(params[:source])
          "#{Format(:bold, "%<type>s")} [%<source>s] %<string>s" % params
        else
          "#{Format(:bold, "%<type>s")} [%<nick>s/%<source>s] %<string>s" % params
        end
      end

    end
  end
end
