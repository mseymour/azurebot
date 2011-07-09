# -*- coding: UTF-8 -*-

require_relative '../_ext/string'

class Attack
  include Cinch::Plugin
	
	react_on :channel
	match /attack\s?(.+)?/

		@@attackdict = [
			"rocket-punches %<target>s in the stomach!",
			"rocket-punches %<target>s in the groin!",
			"FALCON PAWNCHes %<target>s!",
			"rocket-punches %<target>s into a prototype version of options -> forumid, usbid will be coffee niggers!",
			"stabs %<target>s repeatedly in the back with a nail gun, takes the nails out and pours salt into the holes from the nails, drives more nails in, then puts duct tape over the salt-and-nail-filled holes so %<target>s can't get them out!",
			"sends %<target>s flying into a brick wall!",
			"pierces %<target>s with a drill!",
			"shakes %<target>s like a nignog!",
			"swings %<target>s around like a nignog!",
			"hits %<target>s with a harisen!",
			"hits %<target>s with a mallet!",
			"bonks %<target>s on the head with a pikopiko hammer!",
			"smashes %<target>s's head in with a pikopiko hammer!",
			"takes a small computer from it's belt, plugs in a dongle and scans it's thumbprint. %<bot>s then inputs a few coordinates, and then taps something on it. Suddenly, a bright blue beam fires down from the sky, sending clouds circling around it. In a bright flash and a loud explosion, %<target>s is finally neutralized.",
			"attacks %<target>s's life points directly!",
			"feeds %<target>s to sharks!",
			"feeds %<target>s to sharksoda!",
			"forces %<target>s to watch the Super Bowl XLV halftime show Clockwork Orange style!",
			"deletes %<target>s!",
			"divides %<target>s by zero!",
			"hits %<target>s with a hammer", 
			"stabs %<target>s in the face with a combat knife!",
			"stabs %<target>s with a combat knife!",
			"kicks %<target>s in the face!",
			"uses DELTA KICK on %<target>s!",
			"piledrives %<target>s!",
			"piledrives %<assailant>s!",
			"piledrives %<target>s, and then %<assailant>s!",
			"rapes %<target>s with a burning candle!",
			"ties %<target>s up and drips them with a burning candle!",
			"ties %<target>s up and whacks them senseless with a pair of Shinai!",
			"throws %<target>s into a dark void!",
			"kicks %<target>s into a pit!",
			"forces %<target>s into a furry suit and then casts a fire spell!",
			"forces %<target>s into a furry suit and then puts them into a blender!",
			"puts %<target>s in a blender. Don't breathe this!",
			"metals out %<target>s!",
			"impales %<target>s with a commercial jet!",
			"throws %<target>s into a punji pit!",
			"smashes %<target>s's face with a train!",
			"vores %<target>s!",
			"puts %<target>s into a rape tunnel!",
			"rapes %<assailant>s!",
			"rapes %<assailant>s with %<target>s!",
			"rapes %<target>s with %<assailant>s!",
			"punches %<target>s's cunt til it bleeds!",
			"slaps %<target>s around a bit with a large trout!",
			"slaps %<target>s around a bit with a large magikarp!",
			"slaps %<target>s around a bit with a large sebmal!",
			"slaps %<target>s around a bit with a large %<assailant>s!",
			"slaps %<assailant>s around a bit with a large %<target>s!",
			"slaps %<target>s around a bit with a large %<target>s!",
			"slaps %<assailant>s around a bit with a large %<assailant>s!",
			"slaps %<target>s around with a large sandy vagina!",
			"rams a chainsaw through %<target>s's face!",
			"throws %<target>s into a flaming pit of thermite!",
			"shoots %<target>s in the groin with a howitzer!",
			"gets %<target>s grappled by a Takoluka!",
			#"makes %<target>s enter nekomimi mode!",
			"slaps %<target>s with a ![c04]R![c07]A![c08]I![c03]N![c02]B![c13]O![c06]W![c] trout!",
			"blows the crap out of %<target>s!",
			"ends %<target>s with a Bonecrusher Mallet!",
			"glues %<target>s's face to the wall!",
			"handcuffs %<target>s with some furry, pink handcuffs!",
			"sends hordes of lemmings over %<target>s!",
			"throws a milkbag at %<target>s!",
			"throws 10 milkbags at %<target>s!",
			"throws 20 milkbags at %<target>s!",
			"throws 80 milkbags at %<target>s!",
			"throws 1,000,000 milkbags at %<target>s!",
			"makes %<target>s take forty cakes when no one was looking. %<target>s took 40 cakes. That’s as many as four tens. And that’s terrible!",
			"makes %<assailant>s take forty cakes when no one was looking. %<assailant>s took 40 cakes. That’s as many as four tens. And that’s terrible!",
			#"turns %<target>s into a blue-haired loli with uncontrollable prehensile tentacle hair that attacks him!",
			"turns %<target>s into a blue-haired loli with uncontrollable prehensile tentacle hair that attacks %<assailant>s!",
			"turns %<assailant>s into a blue-haired loli with uncontrollable prehensile tentacle hair that attacks %<target>s!",
			"becomes a blue-haired loli with prehensile tentacle hair and attacks %<target>s!",
			"becomes a blue-haired loli with prehensile tentacle hair and attacks %<assailant>s!",
			"becomes a blue-haired loli with prehensile tentacle hair and attacks %<target>s and %<assailant>s!",
			"slaps %<target>s around a bit with a 500lb C++ manual!",
			"slaps %<target>s around a bit with a large bonecrusher mallet!",
			"slaps %<target>s with a big-ass paddle!",
			"slaps %<target>s with a small Banana!",
			"slaps %<target>s with it's very own hand!",
			"straps a bomb onto %<target>s and drops him off a plane!",
			#"transforms into a camera-weilding loli and stalks %<target>s!",
			"casts Expa Abyss on %<target>s!",
			"forces %<target>s into a tunafish costume and puts them into the takoluka tank!",
			"pickles %<target>s!",
			#"lolifies %<target>s!",
			"fucks %<target>s with a big splintering post!",
			"forces %<target>s to play Big Rigs: Over The Road Racing all day long!",
			"mind controls %<target>s and commands them to jump off a cliff!",
			"runs over %<target>s with a FULLY LOADED, 80,000 POUND TRACTOR TRAILER!",
			"turns %<target>s into a honeycomb techno darkie!",
			"shoots %<target>s with a BAR!",
			"shoots %<target>s with a Luger!",
			"shoots %<target>s with a Mauser HSc!",
			"shoots %<target>s with an DEAGLE BRAND DEAGLE but then it jams, and then instead chucks it at %<target>s's head!",
			"shoots %<target>s with an MG-42!",
			"shoots %<target>s with an AR-15!",
			"shoots %<target>s with an AK-47!",
			"throws a Glock at %<target>s like a handgrenade!",
			#"makes Lastplacer sits on %<target>s!",
			#"makes Lastplacer sits on %<assailant>s!",
			"ties %<target>s onto an A6M and sends them on a kamikaze mission!",
			"performs SCIENCE on %<target>s!",
			"transforms %<target>s into a small, pink, tentacled singing monster!",
			"transforms %<target>s into a hot, teal-haired singing robot-thing!",
			"attacks %<target>s with a fluffy tail~!",
			"attacks %<assailant>s with a fluffy tail~!",
			"swings the butt end of an mg-42 at %<target>s!",
			"swings the butt end of an mg-42 at %<assailant>s!",
			"rams a rusty flathead screwdriver into %<target>s's left eye socket!",
			"slaps %<target>s around a bit with a live lobster from a lobster trap. And then proceed to slap them with the lobster trap with even more live lobsters in it!",
			"slaps %<assailant>s around a bit with a live lobster from a lobster trap. And then proceed to slap them with the lobster trap with even more live lobsters in it!",
			"transforms %<target>s into a furry!",
			"transforms %<target>s into a maid (and if applicable also turns them female) and makes them serve %<assailant>s all day!",
			"makes %<target>s wear nothing but a navy uniform and a blue school swimsuit for the whole day!",
			"makes %<target>s wear nothing but a navy uniform and panties for the whole day!",
			"makes %<target>s wear nothing but a military uniform jacket and striped panties for the whole day!",
			"makes %<target>s wear nothing but a military uniform jacket and panties along with animal ears and tail for the whole day, and makes them exclaim \"It's not panties so it's not embarassing!\" every time someone asks them about it!",
			"takes photos of %<target>s in a school swimsuit!",
			"takes photos of %<target>s in a wet school swimsuit!",
			"takes photos of %<target>s and %<assailant>s in wet school swimsuits!",
			"takes photos of %<assailant>s in a wet school swimsuit!",
			"makes %<target>s sit on Leo Laporte's ball, then makes it pop!",
			"turns %<target>s into a l-- JESUS CHRIST IT'S A LION EVERYONE GET IN THE CAR!!!1!",
			"!'s %<target>s!",
			"makes %<target>s take it easy!",
			"gives %<target>s rabies and death!",
			"runs a train through %<target>s's soul!"
		]
	
	def grab_random_nick ( users )
		users.to_a.sample[0].nick;
	end

	def attack! ( target, assailant )
		return nil if target.nil?;
		@@attackdict.sample % {:target => target, :assailant => assailant, :bot => @bot.nick};
	end
	
	def random_attack! ( targets, assailant )
		@@attackdict.sample % {:target => grab_random_nick(targets), :assailant => assailant, :bot => @bot.nick};
	end
		
	def execute (m, target)
		#@bot.debug("(active) attack list length == #{@@attackdict.length}")
		target = m.user.nick if !target.nil? && target.among_case?(@bot.nick, "herself", "himself", "itself");
		@@attackdict.shuffle!;
		output = if target
			attack!(target.irc_strip_colors, m.user.nick)
		else
			random_attack!(m.channel.users, m.user.nick)
		end
		m.channel.action output.irc_colorize;
	end

end