# -*- coding: UTF-8 -*-

require 'cinch'

class Ryder
  include Cinch::Plugin
	
	match /ryder$/

		@@ryderdict = [
			"Beat PunchBeef",
			"Big, Brave Brick of Meat",
			"Big McLargeHuge",
			"Blast HardCheese",
			"Blast ThickNeck",
			"Bob Johnson",
			"Bold BigFlank",
			"Bolt VanderHuge",
			"Brick HardMeat",
			"Buck PlankChest",
			"Buff DrinkLots",
			"Buff HardBack",
			"Butch DeadLift",
			"ChunkHead",
			"Chunky",
			"Crud BoneMeal",
			"Crunch ButtSteak",
			"Dirk HardPec",
			"Fist RockBone",
			"Flink",
			"Flint IronStag",
			"Fridge LargeMeat",
			"Gristle McThornBody",
			"Hack BlowFist",
			"Hunk",
			"Lump BeefBroth",
			"Punch RockGroin",
			"Punch Side-Iron",
			"Punt SpeedChunk",
			"Reef BlastBody",
			"Roll Fizzlebeef",
			"Rip SteakFace",
			"Slab BulkHead",
			"Slab SquatThrust",
			"Slam",
			"Slate Fistcrunch",
			"Slate SlabRock",
			"Smash LampJaw",
			"Smoke ManMuscle",
			"Splint ChestHair",
			"Stump BeefKnob",
			"Stump Chunkman",
			"Thick McRunFast",
			"Touch RustRod",
			"Trunk SlamChest",
			"Whip SlagCheek"
		]

	def ryder!
		@@ryderdict[Random.new.rand(1..@@ryderdict.length)-1]
	end
		
	def execute (m)
		m.reply(ryder!);
	end

end