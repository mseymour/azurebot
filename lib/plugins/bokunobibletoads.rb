module Plugins
  class BokunoBibletoads
    include Cinch::Plugin

    set(
      plugin_name: "Boku no Bibletoads",
      help: "Biblebattle no bokutoads.\nUsage: `!bnbt`")

    match "bnbt"
    def execute m
      words = %w{ bible black battle toads boku pico }
      name = []
      4.times {
        e = words.sample
        name << e
        words.delete(e)
      }
      name.map {|e| e.capitalize }

      part_no = [true,false].sample
      two_parts_a = [true,false].sample
      two_parts_b = [true,false].sample

      format = "#{two_parts_a ? "%s%s" : "%s"}#{part_no ? " no " : ""}#{two_parts_b ? "%s%s" : "%s"}"

      m.reply(format % name)
    end
  end
end
