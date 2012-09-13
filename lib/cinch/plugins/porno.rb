require 'json'
require 'open-uri'
require 'yaml'

module Cinch
  module Plugins
    class Porno
      include Cinch::Plugin

      def initialize(*args)
        super
        # Gets listing, adds yaml file to listing, gets unique values, and saves.
        @pornos = get_listing
        @pornos << YAML.load(open(config[:porno_list_path])) if File.exist?(config[:porno_list_path])
        @pornos.uniq!
        open(config[:porno_list_path], 'w+') {|file| file.write(@pornos.to_yaml)}

        # does the same, but on a timer.
        @timer = Timer(7200) { 
          updates = get_listing
          updates ||= @pornos
          @pornos << updates
          @pornos.uniq! 
          open(config[:porno_list_path], 'w+') {|file| file.write(@pornos.to_yaml)}
        }
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

      def get_listing
        pornos = JSON.parse(open(%q{http://www.directv.com/entertainment/data/guideScheduleSegment.json.jsp?numchannels=14&channelnum=586&blockdur=24}).read)

        return nil if !pornos["success"]

        pornos["channels"].each_with_object([]) {|channel,memo|
          channel["schedules"].each {|program|
            next if program["productType"].empty? || !program["repeat"]
            memo << program["prTitle"]
          }
        }.uniq
      end
    end
  end
end
