Azurebot
========

A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

Plugins
-------

### basicctcp (`Cinch::Plugins::BasicCTCP`)

(No help available)

### downforeveryone (`Cinch::Plugins::DownForEveryone`)

(No help available)

### identify (`Cinch::Plugins::Identify`)

(No help available)

### admin (`Plugins::AdminHandler`)

Admin handler -- handles admins, of course.

### authtest (`Plugins::Authtest`)

Tells you if you are logged into the bot or not. (Admins only)

### 8ball (`Plugins::Eightball`)

The Magic 8ball has all the answers!

Usage: `!8ball [question? <question? <...>>]`

### Attacker (`Plugins::Attack`)

Attacks a user with a random attack.

Usage: `!attack <nick or phrase>`; `<nick or phrase>` may be omitted for a random attack on a random nick.

### Auto OP (`Plugins::AutoOP`)

Automatically ops nicks upon join.

Usage: `!autoop [on|off]` -- turns autoop on or off. (Admins only)

### Auto Voice (`Plugins::AutoVoice`)

Automatically voices nicks upon join.

Usage: `!autovoice [on|off]` -- turns autovoice on or off. (Admins only)

### Booru (`Plugins::Booru`)

Generates a handy link to a *booru search

Usage: `!booru <selector> <comma-separated list of tags>`; use `!booru` to get a list of tags.

### botinfo (`Plugins::BotInfo`)

Notices you information about me.

Usage: `!Aiko`

### Decider (`Plugins::Decide`)

Helps you decide on things.

Usage: `!decide [a list of items separated by ", ", ", or", or " or "]`; Usage: `!coin`

### Dicebox (`Plugins::Dice`)

Dicebox -- Uses standard dice notation.

Usage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)

### Auto Notice (`Plugins::JoinNotice`)

Notices nicks upon join.

Usage: `!hello` to reply entry notice.

### Kickban (`Plugins::Kickban`)

Various commands used for kickbanning users.

Usage: `!moon [nick]` -- kicks the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.

Usage: `!sun` -- Kickbans the selected user [MLP-themed]

Usage: `!banana` -- Kicks too. Don't ask.

### QDB (`Plugins::MultiQDB`)

Pulls a quote from a QDB.

`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.

### Private toolbox (`Plugins::PrivToolbox`)

Bot administrator-only private commands.

Usage: n/a

### Rainbow (`Plugins::Rainbow`)

Rainbowificates your text.

Usage: `!rainbow [text]`.

### Ryder (`Plugins::Ryder`)

Beat PunchBeef! Blast Thickneck! Big McLargehuge!

Usage: `!ryder`

### silly (`Plugins::Silly`)

You know, silly stuff.

### Toolbox (`Plugins::Toolbox`)

Bot administrator-only private commands.

Usage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;

### Twitter (`Plugins::Twitter5`)

Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.

Usage: `!tw<itter> [username] <info>`

### Weather (`Plugins::Weather`)

Grabs the current weather from Google and WeatherUnderground.

Usage: `!weather [query]`

Commands
--------

As a note, all commands shown here are generated from the plugin's matches, composited with their individual prefices and suffices (if applicable.)

### basicctcp (`Cinch::Plugins::BasicCTCP`)

* `^!basicctcp`

### downforeveryone (`Cinch::Plugins::DownForEveryone`)

* `^!isit(?:down|up)\?? (.+)`

### identify (`Cinch::Plugins::Identify`)

* `^!identify`

### admin (`Plugins::AdminHandler`)

* `^login (.+)`
* `^logout`
* `^admins`

### authtest (`Plugins::Authtest`)

* `^Am I (logged in|an admin)\?$`

### 8ball (`Plugins::Eightball`)

* `^!8ball (.+)`

### Attacker (`Plugins::Attack`)

* `^!attack\s?(.+)?`

### Auto OP (`Plugins::AutoOP`)

* `^!autoop (on|off)$`

### Auto Voice (`Plugins::AutoVoice`)

* `^!autovoice (on|off)$`

### Booru (`Plugins::Booru`)

* `^!booru\s?(\w+)?\s?(.+)?`

### botinfo (`Plugins::BotInfo`)

* `^!generate documentation`
* `^!Aiko$`

### Decider (`Plugins::Decide`)

* `^!decide (.+)`
* `^!choose (.+)`
* `^!coin$`

### Dicebox (`Plugins::Dice`)

* `^(\d*#)?(\d+)d(\d+)`

### Auto Notice (`Plugins::JoinNotice`)

* `^!hello$`

### Kickban (`Plugins::Kickban`)

* `^!moon (.+)`
* `^!sun (.+)`
* `^!banana (.+)`

### QDB (`Plugins::MultiQDB`)

* `^!qdb\s?(\w+)?\s?(.+)?`

### Private toolbox (`Plugins::PrivToolbox`)

* `^say (#\S+) (.+)`
* `^act (#\S+) (.+)`
* `^cs (.+)`
* `^ns (.+)`
* `^hs (.+)`

### Rainbow (`Plugins::Rainbow`)

* `^!rainbow (.+)$`

### Ryder (`Plugins::Ryder`)

* `^!ryder$`

### silly (`Plugins::Silly`)

* `\x01ACTION pokes (.+)\x01`
* `dumb bot`

### Toolbox (`Plugins::Toolbox`)

* `^~join (.+)`
* `^~part(?: (\S+)\s?(.+)?)?`
* `^~quit(?: (.+))?`
* `^~nick (.+)`
* `^~opadmin$`

### Twitter (`Plugins::Twitter5`)

* `^!tw$`
* `^!twitter$`
* `^!tw (.+)*`
* `^!twitter (.+)*`

### Weather (`Plugins::Weather`)

* `^!weather (.+)`

Author information
------------------
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net