require 'yaml'

module Cinch
  module Plugins
    class Porno
      include Cinch::Plugin

      set help: "Random porno film names.\nUsage: `!porno [search term]`", required_options: [:porno_list_path]

      match /porno(?> )?(.+)?/, method: :execute_porno
      def execute_porno(m, search)
        pornos = YAML.load(open(config[:porno_list_path]))
        if search
          results = pornos.find_all {|title| title =~ /#{Regexp.escape(search)}/i }
          m.reply (results.empty? ? pornos : results).sample, true
        else
          m.reply pornos.sample, true
        end
      end
    end
  end
end