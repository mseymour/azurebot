# -*- coding: UTF-8 -*-

module Plugins
	class Ryder
		include Cinch::Plugin

		set(
			plugin_name: "Ryder",
			help: "Beat PunchBeef! Blast Thickneck! Big McLargehuge!\nUsage: `!ryder`")

		@@ryderdict = [
			["Beat", "PunchBeef"],
			["Big, Brave Brick of", "Meat"],
			["Big", "McLargeHuge"],
			["Blast", "HardCheese"],
			["Blast", "ThickNeck"],
			["Bob", "Johnson"],
			["Bold", "BigFlank"],
			["Bolt", "VanderHuge"],
			["Brick", "HardMeat"],
			["Buck", "PlankChest"],
			["Buff", "DrinkLots"],
			["Buff", "HardBack"],
			["Butch", "DeadLift"],
			["ChunkHead",""],
			["Chunky",""],
			["Crud", "BoneMeal"],
			["Crunch", "ButtSteak"],
			["Dirk", "HardPec"],
			["Fist", "RockBone"],
			["Flink",""],
			["Flint", "IronStag"],
			["Fridge", "LargeMeat"],
			["Gristle", "McThornBody"],
			["Hack", "BlowFist"],
			["Hunk", ""],
			["Lump", "BeefBroth"],
			["Punch", "RockGroin"],
			["Punch", "Side-Iron"],
			["Punt", "SpeedChunk"],
			["Reef", "BlastBody"],
			["Roll", "Fizzlebeef"],
			["Rip", "SteakFace"],
			["Slab", "BulkHead"],
			["Slab", "SquatThrust"],
			["Slam", ""],
			["Slate", "Fistcrunch"],
			["Slate", "SlabRock"],
			["Smash", "LampJaw"],
			["Smoke", "ManMuscle"],
			["Splint", "ChestHair"],
			["Stump", "BeefKnob"],
			["Stump", "Chunkman"],
			["Thick", "McRunFast"],
			["Touch", "RustRod"],
			["Trunk", "SlamChest"],
			["Whip", "SlagCheek"]
		]

		def ryder!
			[@@ryderdict.sample[0], @@ryderdict.sample[1]].reject(&:empty?).join(" ")
		end
			
		match /ryder$/
		def execute (m)
			m.reply(ryder!);
		end

	end
end