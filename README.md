Azurebot
========

A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

Plugins
-------

### basicctcp (`Cinch::Plugins::BasicCTCP`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!basicctcp`

### downforeveryone (`Cinch::Plugins::DownForEveryone`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!isit(?:down|up)\?? (.+)`

### identify (`Cinch::Plugins::Identify`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!identify`

### joker (`Cinch::Plugins::Joker`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!joke`

### hangman (`Cinch::Plugins::Hangman`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!hang guess (.*)`
* `^!hang new (#\S*) ([\sa-zA-Z0-9]*)`

### fortune (`Cinch::Plugins::Fortune`)

(No help available)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!fortune`

### Admin (`Plugins::AdminHandler`)

Admin handler -- handles admins, of course.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^login (.+)`
* `^logout`
* `^flogout`
* `^list admins`

### Antispam Kicker (`Plugins::AntiSpam::Kicker`)

Kicks those who spam prefixed bot commands.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!Antispam Kicker`

### Antispam Lister (`Plugins::AntiSpam::Lister`)

List those who spam prefixed bot commands.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^list abusers`

### Admin auth checker (`Plugins::Authtest`)

Tells you if you are logged into the bot or not. (Admins only)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^Am I (logged in|an admin)\?$`

### 8ball (`Plugins::Eightball`)

The Magic 8ball has all the answers!

Usage: `!8ball [question? <question? <...>>]`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!8ball (.+)`

### Random Attacker (`Plugins::Attack`)

Attacks a user with a random attack.

Usage: `!attack <nick or phrase>`; `<nick or phrase>` may be omitted for a random attack on a random nick.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!attack\s?(.+)?`

### Auto OP (`Plugins::AutoOP`)

Automatically ops nicks upon join.

Usage: `!autoop [on|off]` -- turns autoop on or off. (Admins only)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!autoop (on|off)$`

### Auto Voice (`Plugins::AutoVoice`)

Automatically voices nicks upon join.

Usage: `!autovoice [on|off]` -- turns autovoice on or off. (Admins only)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!autovoice (on|off)$`

### Booru (`Plugins::Booru`)

Generates a handy link to a *booru search

Usage: `!booru <selector> <comma-separated list of tags>`; use `!booru` to get a list of tags.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!booru$`
* `^!booru (\w+)?\s?(.+)?`
* `^!boorulist`

### Botinfo (`Plugins::BotInfo`)

Notices you information about me.

Usage: `![botnick]`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!generate documentation`
* `^!(.+)$`
* `^!plugins$`

### Decider (`Plugins::Decide`)

Helps you decide on things.

Usage: `!decide [a list of items separated by ", ", ", or", or " or "]`; Usage: `!coin`; Usage: `!rand [x] [y]`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!decide (.+)`
* `^!choose (.+)`
* `^!coin$`
* `^!rand ((?-mix:(?:-|\+)?\d*\.?\d+(?:e)?(?:-|\+)?\d*\.?\d*)) ((?-mix:(?:-|\+)?\d*\.?\d+(?:e)?(?:-|\+)?\d*\.?\d*))`
* `^!token (\d+)`

### Delayed Rejoin (`Plugins::DelayedRejoin`)

If the bot is kicked, it will attempt to rejoin after 10 seconds by default.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!Delayed Rejoin`

### Dicebox (`Plugins::Dice`)

Dicebox -- Uses standard dice notation.

Usage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^(\d*#)?(\d+)d(\d+)`

### Jargon File (`Plugins::JargonFile`)

Gets the entry from the Jargon File.

Usage: `!jargon <entry>`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!jargon (.+)`

### Auto Notice (`Plugins::JoinNotice`)

Notices nicks upon join.

Usage: `!hello` to replay entry notice.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!hello$`

### Kickban (`Plugins::Kickban`)

Various commands used for kickbanning users.

Usage: `!moon [nick]` -- kicks the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.

Usage: `!sun [nick]` -- Kickbans the selected user [MLP-themed]

Usage: `!banana [nick]` -- Kicks too. Don't ask.

Usage: `!crp [nick]` -- Also kicks too. Don't ask, as well.

Usage: `!fus [nick]` -- I really need to come up with a better solution for this.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!moon (.+)`
* `^!sun (.+)`
* `^!banana (.+)`
* `^!crp (.+)`
* `^!fus (.+)`

### QDB (`Plugins::MultiQDB`)

Pulls a quote from a QDB.

`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!qdb\s?(\w+)?\s?(.+)?`

### Ping (`Plugins::Ping`)

Pings you or a target via CTCP, and reports the number of milliseconds on recieving a response.

Usage: `!ping <nick>`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!ping(?:\s(\S+))?`

### Private toolbox (`Plugins::PrivToolbox`)

Bot administrator-only private commands.

Usage: n/a

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^say (#\S+) (.+)`
* `^act (#\S+) (.+)`
* `^cs (.+)`
* `^ns (.+)`
* `^hs (.+)`
* `^psa (.+)`
* `^kick (#\S+) (\S+)\s?(.+)?`
* `^ban (#\S+) (\S+)`
* `^unban (#\S+) (\S+)`
* `^kb (#\S+) (\S+)\s?(.+)?`

### Rainbow (`Plugins::Rainbow`)

Rainbowificates your text.

Usage: `!rainbow [text]`.

Usage: `eyerape [text]`.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!rainbow (.+)$`
* `^!eyerape (.+)$`

### Remote admin (`Plugins::RemoteAdmin`)

Relays certain messages to logged-in admins.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!Remote admin`

### Russian Roulette (`Plugins::RussianRoulette`)

In Soviet Russia, boolet shoots YOU!

Usage: !rr <nick>

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!rr(?:\s(.+))?`

### Ryder (`Plugins::Ryder`)

Beat PunchBeef! Blast Thickneck! Big McLargehuge!

Usage: `!ryder`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!ryder$`

### Silly (`Plugins::Silly`)

You know, silly stuff.

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `\b(dumb|stupid)\b.+\bbot\b`
* `^!xmas`

### Toolbox (`Plugins::Toolbox`)

Bot administrator-only private commands.

Usage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^~join (.+)`
* `^~part(?: (\S+)\s?(.+)?)?`
* `^~quit(?: (.+))?`
* `^~nick (.+)`
* `^~opadmin$`
* `^~isupport$`

### Twitter (`Plugins::Twitter5`)

Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.

Usage: `!tw<itter> [params[:username]] <info>`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!tw$`
* `^!twitter$`
* `^!tw (.+)*`
* `^!twitter (.+)*`

### Urban Dictionary (`Plugins::UrbanDictionary`)

Gets the first entry for an entry on UrbanDictionary.

Usage: `!urban <entry>`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!urban (.+)`

### Weather (`Plugins::Weather`)

Grabs the current weather from WeatherUnderground.

Usage: `!weather [query]`

#### Matchers
Commands that the bot reacts to; It will return the plugin name as a matcher if there are none defined.

* `^!weather (.+)`

Author information
------------------
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net