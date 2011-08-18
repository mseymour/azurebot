Azurebot
========

A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

Plugins
-------

### authtest (Authtest)

Tells you if you are logged into the bot or not.

### admin (AdminHandler)

Admin handler -- handles admins, of course.

### basicctcp (Cinch::Plugins::BasicCTCP)

(No help available)

### identify (Cinch::Plugins::Identify)

(No help available)

### 8ball (Eightball)

The Magic 8ball has all the answers!

Usage: !8ball [question? <question? <...>>]

### Attacker (Attack)

Attacks a user with a random attack.

Usage: !attack <nick or phrase>; <nick or phrase> can be omitted for a random attack on a random nick.

### Auto OP (AutoOP)

Automatically ops nicks upon join.

Usage: !autoop [on|off] -- turns autoop on or off.

### Auto Voice (AutoVoice)

Automatically voices nicks upon join.

Usage: !autovoice [on|off] -- turns autovoice on or off.

### Booru (Booru)

Generates a handy link to a *booru search

Usage: !booru <selector> <comma-separated list of tags>; use !booru to get a list of tags.

### botinfo (BotInfo)

Notices you information about me.

Usage: !Azurebot

### Decider (Decide)

Helps you decide on things

Usage: !decide [a list of items separated by ", ", ", or", or " or ".

Usage: !coin]

### Dicebox (Dice)

Dicebox -- Uses standard dice notation.

Usage: <X#>YdZ<[+|-]A> (Examples: 1d6; 2d6-3; 2#1d6; 5#2d6+10)

### Auto Notice (JoinNotice)

Notices nicks upon join.

Usage: !hello to reply entry notice.

### Kickban (Kickban)

Various commands used for kickbanning users.

Usage: !moon [nick] -- kickbans the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.

### QDB (MultiQDB)

Pulls a quote from a QDB.

Usage: !qdb <selector> <ID|latest>; !qdb for selector list.

### Private toolbox (PrivToolbox)

Bot administrator-only private commands.

Usage: n/a

### Rainbow (Rainbow)

rainbow -- gaaaaaaay.

### Ryder (Ryder)

Beat PunchBeef! Black Thickneck! Big McLargehuge!

Usage: !ryder

### silly (Silly)

You know, silly stuff.

### Toolbox (Toolbox)

Bot administrator-only private commands.

Usage: ~join [channel]; ~part [channel] <reason>; ~quit [reason]; ~nick [newnick]; ~opadmin;

### Twitter (Twitter5)

Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.

Usage: !tw<itter> [username] <info>

### Weather (Weather)

Grabs the current weather from Google and WeatherUnderground.

Usage: !weather [query]

Commands
--------

As a note, all commands shown here are generated from the plugin's matches, composited with their individual prefices and suffices (if applicable.)

### authtest (Authtest)

* `^Am I (logged in|an admin)\?$`

### admin (AdminHandler)

* `^login (.+)`
* `^logout`
* `^admins`

### basicctcp (Cinch::Plugins::BasicCTCP)

* `^!basicctcp`

### identify (Cinch::Plugins::Identify)

* `^!identify`

### 8ball (Eightball)

* `^!8ball (.+)`

### Attacker (Attack)

* `^!attack\s?(.+)?`

### Auto OP (AutoOP)

* `^!autoop (on|off)$`

### Auto Voice (AutoVoice)

* `^!autovoice (on|off)$`

### Booru (Booru)

* `^!booru\s?(\w+)?\s?(.+)?`

### botinfo (BotInfo)

* `^!retrieve plugin classes`
* `^!Azurebot$`

### Decider (Decide)

* `^!decide (.+)`
* `^!choose (.+)`
* `^!coin$`

### Dicebox (Dice)

* `^(\d*#)?(\d+)d(\d+)`

### Auto Notice (JoinNotice)

* `^!hello$`

### Kickban (Kickban)

* `^!moon (.+)`
* `^!sun (.+)`
* `^!banana (.+)`

### QDB (MultiQDB)

* `^!qdb\s?(\w+)?\s?(.+)?`

### Private toolbox (PrivToolbox)

* `^say (#\S+) (.+)`
* `^act (#\S+) (.+)`
* `^cs (.+)`
* `^ns (.+)`
* `^hs (.+)`

### Rainbow (Rainbow)

* `^!rainbow (.+)$`

### Ryder (Ryder)

* `^!ryder$`

### silly (Silly)

* `\x01ACTION pokes (.+)\x01`
* `dumb bot`

### Toolbox (Toolbox)

* `^~join (.+)`
* `^~part(?: (\S+)\s?(.+)?)?`
* `^~quit(?: (.+))?`
* `^~nick (.+)`
* `^~opadmin$`

### Twitter (Twitter5)

* `^!tw$`
* `^!twitter$`
* `^!tw (.+)*`
* `^!twitter (.+)*`

### Weather (Weather)

* `^!weather (.+)`

Author information
------------------
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net