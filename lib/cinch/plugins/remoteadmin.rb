module Cinch
  module Plugins
    class RemoteAdmin
      include Cinch::Plugin

      set plugin_name: "Remote admin", help: "Relays certain messages to logged-in admins."

      listen_to :private, method: :listen_private
      def listen_private(m, message = nil, target = nil)
        return if m.ctcp? || m.events.include?(:notice)
        Channel(shared[:controlchannel]).msg prettify(nick: m.user.nick, source: m.target.name, type: m.command, string: m.message)
      end

      listen_to :notice, method: :listen_notice
      def listen_notice(m, message = nil, target = nil)
        return if m.ctcp? || !m.user
        Channel(shared[:controlchannel]).msg prettify(nick: m.user.nick, source: m.target.name, type: m.command, string: m.message)
      end

      listen_to :ctcp, method: :listen_ctcp
      def listen_ctcp(m, message = nil, target = nil)
        return if !m.ctcp? || m.action?
        Channel(shared[:controlchannel]).msg prettify(nick: m.user.nick, source: m.target.name, type: "CTCP", string: m.ctcp_message)
      end

      listen_to :admin, method: :listen_hook
      listen_to :private_admin, method: :listen_hook
      def listen_hook(m, message, target)
        Channel(shared[:controlchannel]).msg prettify(nick: m.user.nick, source: m.target.name, type: "ADMIN", string: message)
      end

      #listen_to :antispam, method: :listen_hook_antispam
      #def listen_hook_antispam(m, message, target)
        #Channel(shared[:controlchannel]).msg ":antispam m: #{m.inspect}; message: #{message.inspect}; target: #{target.inspect}; command: #{m.command}; events: #{m.events.inspect}"
      #end

      private

      def prettify(params={})
        params = {
          nick: "?",
          source: "?",
          type: "---",
          string: ""
        }.merge params
        "#{Format(:bold, "%<type>s")} [%<nick>s/%<source>s] %<string>s" % params
      end

    end
  end
end
