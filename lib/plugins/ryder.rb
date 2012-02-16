# -*- coding: utf-8 -*-

module Plugins
  class Ryder
    include Cinch::Plugin

    set(
      plugin_name: "Ryder",
      help: "Beat PunchBeef! Blast Thickneck! Big McLargehuge!\nUsage: `!ryder`")

    @@ryderdict = [
      ["Slab", "Bulkhead"],
      ["Bridge", "Largemeat"],
      ["Punt", "Speedchunk"],
      ["Butch", "Deadlift"],
      ["Hold", "Bigflank"],
      ["Splint", "Chesthair"],
      ["Flint", "Ironstag"],
      ["Bolt", "Vanderhuge"],
      ["Thick", "McRunfast"],
      ["Blast", "Hardcheese"],
      ["Buff", "Drinklots"],
      ["Crunch", "Slamchest"],
      ["Fist", "Rockbone"],
      ["Stump", "Beefknob"],
      ["Smash", "Lampjaw"],
      ["Punch", "Rockgroin"],
      ["Buck", "Plankchest"],
      ["Stump", "Junkman"],
      ["Dirk", "Hardpec"],
      ["Rip", "Steakface"],
      ["Slate", "Slabrock"],
      ["Crud", "Bonemeal"],
      ["Brick", "Hardmeat"],
      ["Rip", "Slagcheek"],
      ["Punch", "Sideiron"],
      ["Gristle", "McThornbody"],
      ["Slate", "Fistcrunch"],
      ["Buff", "Hardback"],
      ["Bob", "Johnson"],
      ["Blast", "Thickneck"],
      ["Crunch", "Buttsteak"],
      ["Slab", "Squatthrust"],
      ["Lump", "Beefbroth"],
      ["Touch", "Rustrod"],
      ["Beef", "Blastbody"],
      ["Big", "McLargehuge"],
      ["Smoke", "Manmuscle"],
      ["Beat", "Punchmeat"],
      ["Hack", "Blowfist"],
      ["Roll", "Fizzlebeef"]
    ]

    def ryder!
      [@@ryderdict.sample[0], @@ryderdict.sample[1]].reject(&:empty?).join(" ")
    end

    match "ryder"
    def execute(m)
      m.reply(ryder!);
    end

  end
end
