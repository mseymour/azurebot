module Plugins
  class BokunoBibletoads
    include Cinch::Plugin

    match /bnbt/
    def execute m
      words = %w{ bible black battle toads boku pico }
      name = []
      4.times {
        e = words.sample
        name << e
        words.delete(e)
      }
      name.map {|e| e.capitalize }

      m.reply ("%s%s no %s%s" % name)
    end
  end
end