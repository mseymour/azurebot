# coding: utf-8
require 'tag_formatter'

module Cinch
  module Plugins
    class Lewd
      include Cinch::Plugin

      def initialize(*args)
        super
        @lines = [
          "Ahhh, {nick}! My ass is being used as a pussy!",
          "HAaaa~ Ahhh~ Y-yes! My ass is being ravaged!",
          "Ahhhhhhh~! Inside my ass... it's so hot!",
          "I'm gonna cum from my asshole! \x0304♥\x03 I'm gonna have a SHITGASM!! OHH~",
          "JUST SHUT THE FUCK UP AND FUCK MY ASS!",
          "I KEEP FARTING EVERY TIME YOU GO IN AND OUT!",
          "Now that I'm actually squirting in {nick}'s face, all my fears seem to have vanished.",
          "Ahh... Noo... If you suck it like that, I'll c-cum...!! Haah...",
          "N-no! Not there! Ahn~ {nick}-senpai! Ahhhn~ Haaa~ Paah-",
          "Aahhn~ I want all your milk-man-juice {nick}-senpai! Fire your rocket deep inside me!",
          "No way... when you feel my vagina I can taste your fingers...",
          "Wow, you came so much! Even though you came just now... it got hard again immediately!",
          "Aah~ I can feel it hitting my deepest parts... WE ARE CONNECTED... SO... GOOD HAA~",
          "It's going even deeper inside! How far in is it going? Ahh~",
          "Ahh... P-please cum in me... I don't want to make a mess! Hhaa~",
          "Your semen shower feels so good {nick}-senpai! Than you very much \x0304♥\x03",
          "AH!!! Wow... I'm shooting sperm from my {adj1} nipples! \x0304♥\x03",
          "You're penetrating me with your nipple! Ahh~",
          "I think I'm going to get pregnant through the tits!",
          "I'm being fucked by your {adj1} cock! \x0304♥\x03",
          "OH FUCK! You came in my nose!",
          "I'm floating on cocks! Ahn~",
          "IT'S THE BEST FREAKIN' COCK EVER!",
          "Sandwich fuck feels so good...",
          "I'M BECOMING A SLAVE FOR THICK, LONG AND HARD MEGACOCKS!",
          "THE COCKS ARE GOING UP TO MY BRAIN!",
          "IT... IT FEELS REALLY GOOD! Haa... \x0304♥\x03",
          "AHH! \x0304♥\x03 Sex feels so good! \x0304♥\x03",
          "IT'S PUMPING AND PULSING INSIDE ME! AAAH \x0304♥\x03",
          "I want yours... in my mouth, {nick}-senpai. Ahh~ yes... itadakimasu!",
          "You're filling my mouth pussy with your penis-sauce, {nick}!",
          "Ahh~ don't cum inside my mouth! N-no... you're going to make me pregnant! Hhaa~",
          "Brush my teeth with your dick!",
          "I'm licking cheese off {nick}'s cock!",
          "Your... penis juice... is delicious... \x0304♥\x03",
          "Ooohh. \x0304♥\x03 It's knocking on the door to my baby factory! \x0304♥\x03",
          "I... I'm cumming from my womb! I've never cum so hard in my whole life!",
          "DO IT! DO IT! Pour your cum all over my unborn fetus! \x0304♥\x03",
          "Dick! Dick! Hard! Hard! Yeah! Yeah! Yeah! P-pussy c-cumming~!!",
          "Ahe.. \x0304♥\x03 Beniiis \x0304♥\x03 Benis feels good... \x0304♥\x03 Ma, maru..\x0304♥\x03",
          "NHooOooooo! \x0304♥\x03 It came! Benis milk came! \x0304♥\x03"
        ]
        @adj1 = %w{big colossal fat gigantic great huge immense large little mammoth massive miniature petite puny scrawny short small teeny teeny-tiny tiny}
      end

      match /lewd\s?(\d+)?/, method: :execute_lewd
      def execute_lewd(m, lns)
        lns ||= 1
        lns = 5 if lns.to_i > 5
        tf = TagFormatter.new(@lines.sample(lns.to_i) * ' ', tags: {nick: m.user.nick, adj1: @adj1.sample})
        m.reply(tf.parse)
      end
    end
  end
end