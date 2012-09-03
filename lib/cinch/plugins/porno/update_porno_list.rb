require 'json'
require 'open-uri'
require 'yaml'

yaml_file_name = File.expand_path('pornos.yml', File.dirname(__FILE__))
blacklist = YAML.load(open(File.expand_path('porno_blacklist.yml', File.dirname(__FILE__))))
autoreplace = {
  'F...' => 'Fuck',
  'Gangb...' => 'Gangbang',
}
pornos = JSON.parse(open(%q{http://www.directv.com/entertainment/data/guideScheduleSegment.json.jsp?numchannels=14&channelnum=586&blockdur=24}).read)

return warn("Download was unsuccessful, please try again later.") if !pornos["success"]

stored_list = YAML.load(open(yaml_file_name))

current_list = pornos["channels"].each_with_object([]) {|channel,memo|
  channel["schedules"].each {|program|
    next if program["productType"].empty? || !program["repeat"]
    next if blacklist.any? {|badword| program["prTitle"] =~ /\b#{Regexp.escape(badword)}\b/i }
    title = program["prTitle"]
    title.gsub!(/(\w+\.\.\.)/i, autoreplace)
    memo << program["prTitle"]
  }
}.uniq

(current_list - stored_list).each {|title| puts "New title: #{title}"}
puts "No new titles were added." if (current_list - stored_list).empty?

open(yaml_file_name, 'w+') {|file| file.write((stored_list | current_list).to_yaml) }

puts "Update successful."
