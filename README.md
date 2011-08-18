# Azurebot
a Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

- - -

## Plugins

### authtest
Tells you if you are logged into the bot or not.
#### Commands
* `^Am I (logged in|an admin)\?$`

### admin
Admin handler -- handles admins, of course.
#### Commands
* `^login (.+)`
* `^logout`
* `^admins`

### basicctcp
#### Commands
* `^!basicctcp`

### identify
#### Commands
* `^!identify`

### 8ball
The Magic 8ball has all the answers!

Usage: !8ball [question? <question? <...>>]
#### Commands
* `^!8ball (.+)`

### Attacker
Attacks a user with a random attack.

Usage: !attack <nick or phrase>; <nick or phrase> can be omitted for a random attack on a random nick.
#### Commands
* `^!attack\s?(.+)?`

### Auto OP
Automatically ops nicks upon join.

Usage: !autoop [on|off] -- turns autoop on or off.
#### Commands
* `^!autoop (on|off)$`

### Auto Voice
Automatically voices nicks upon join.

Usage: !autovoice [on|off] -- turns autovoice on or off.
#### Commands
* `^!autovoice (on|off)$`

### Booru
Generates a handy link to a *booru search

Usage: !booru <selector> <comma-separated list of tags>; use !booru to get a list of tags.
#### Commands
* `^!booru\s?(\w+)?\s?(.+)?`

### botinfo
Notices you information about me.

Usage: !Azurebot
#### Commands
* `^!retrieve plugin classes`
* `^!Azurebot$`

### Decider
Helps you decide on things

Usage: !decide [a list of items separated by ", ", ", or", or " or ".

Usage: !coin]
#### Commands
* `^!decide (.+)`
* `^!choose (.+)`
* `^!coin$`

### Dicebox
Dicebox -- Uses standard dice notation.

Usage: <X#>YdZ<[+|-]A> (Examples: 1d6; 2d6-3; 2#1d6; 5#2d6+10)
#### Commands
* `^(\d*#)?(\d+)d(\d+)`

### Auto Notice
Notices nicks upon join.

Usage: !hello to reply entry notice.
#### Commands
* `^!hello$`

### Kickban
Various commands used for kickbanning users.

Usage: !moon [nick] -- kickbans the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.
#### Commands
* `^!moon (.+)`
* `^!sun (.+)`
* `^!banana (.+)`

### QDB
Pulls a quote from a QDB.

Usage: !qdb <selector> <ID|latest>; !qdb for selector list.
#### Commands
* `^!qdb\s?(\w+)?\s?(.+)?`

### Private toolbox
Bot administrator-only private commands.

Usage: n/a
#### Commands
* `^say (#\S+) (.+)`
* `^act (#\S+) (.+)`
* `^cs (.+)`
* `^ns (.+)`
* `^hs (.+)`

### Rainbow
rainbow -- gaaaaaaay.
#### Commands
* `^!rainbow (.+)$`

### Ryder
Beat PunchBeef! Black Thickneck! Big McLargehuge!

Usage: !ryder
#### Commands
* `^!ryder$`

### silly
You know, silly stuff.
#### Commands
* `\x01ACTION pokes (.+)\x01`
* `dumb bot`

### Toolbox
Bot administrator-only private commands.

Usage: ~join [channel]; ~part [channel] <reason>; ~quit [reason]; ~nick [newnick]; ~opadmin;
#### Commands
* `^~join (.+)`
* `^~part(?: (\S+)\s?(.+)?)?`
* `^~quit(?: (.+))?`
* `^~nick (.+)`
* `^~opadmin$`

### Twitter
Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.

Usage: !tw<itter> [username] <info>
#### Commands
* `^!tw$`
* `^!twitter$`
* `^!tw (.+)*`
* `^!twitter (.+)*`

### Weather
Grabs the current weather from Google and WeatherUnderground.

Usage: !weather [query]
#### Commands
* `^!weather (.+)`

- - -

## Author information
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net