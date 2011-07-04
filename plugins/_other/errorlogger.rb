require "cinch/logger/logger"
module Cinch
  module Logger
    # A logger that will log all errors and debug messages to file.
    class ErrorLogger < Cinch::Logger::Logger

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