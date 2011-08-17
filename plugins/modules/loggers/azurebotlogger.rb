require "cinch/logger/logger"
module Cinch
  module Logger
    # A logger.
    class AzurebotLogger < Cinch::Logger::Logger

      # @param [IO] output An IO to log to.
      def initialize(output = STDERR)
        @output = output
        @mutex = Mutex.new
      end

      # (see Logger::Logger#debug)
      def debug(messages)
        log(messages, :debug)
      end

      # (see Logger::Logger#log)
      def log(messages, kind = :generic)
        @mutex.synchronize do
          messages = [messages].flatten.map {|s| s.to_s.chomp}
          messages.each do |msg|
            next if msg.empty?
            message = Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L] ")
            if kind == :debug
              prefix = "!! "
              message << prefix + msg
            else
              pre, msg = msg.split(" :", 2)
              pre_parts = pre.split(" ")

              if kind == :incoming
                prefix = ">> "

                if pre_parts.size == 1
                  pre_parts[0] = pre_parts[0]
                else
                  pre_parts[0] = pre_parts[0]
                  pre_parts[1] = pre_parts[1]
                end

              elsif kind == :outgoing
                prefix = "<< "
                pre_parts[0] = pre_parts[0]
              end

              message << prefix + pre_parts.join(" ")
              message << " :#{msg}" if msg
            end
            @output.puts message.encode("locale", {:invalid => :replace, :undef => :replace})
          end
        end
      end

      # (see Logger::Logger#log_exception)
      def log_exception(e)
        lines = ["#{e.backtrace.first}: #{e.message} (#{e.class})"]
        lines.concat e.backtrace[1..-1].map {|s| "\t" + s}
        debug(lines)
      end
    end
  end
end