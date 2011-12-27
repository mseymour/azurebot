require 'yaml'

module Plugins
  class DJInfo
    include Cinch::Plugin

    set plugin_name: "DJ Info", help: "Spams the channel with DJ contact information.\nUsage: `!dj <dj_name>`", required_options: [:dj_info]

    match /dj\s?(.+)?/
    def execute (m, target)
      info = YAML::load_file(config[:dj_info])

      if !target.nil? && info.has_key?(target.downcase)
        info[target.downcase].each {|key,item|
          m.reply "#{key}: #{item}"
        }
      elsif target.nil?
        m.user.notice "DJInfo: No DJ name was supplied."
      else
        m.user.notice "\"#{target}\" is not a DJ, sorry."
      end
    end
  end
end
