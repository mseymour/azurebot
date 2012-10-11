require 'yaml'

module Cinch
  module Plugins
    class Porno
      include Cinch::Plugin

      set required_options: [:porno_list_path]

      def initialize(*args)
        super
        update_porno_list
        @timer = Timer(7200, method: :update_porno_list)
      end

      match /porno(?> )?(.+)?/, method: :execute_porno
      def execute_porno(m, search)
        if search
          results = @pornos.find_all {|title| title =~ /#{Regexp.escape(search)}/i }
          m.reply (results.empty? ? @pornos : results).sample, true
        else
          m.reply @pornos.sample, true
        end
      end

      private

      def update_porno_list
        @pornos = YAML.load(open(config[:porno_list_path]))
      end
    end
  end
end