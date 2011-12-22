Azurebot
========

A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

Plugins
-------

### basicctcp

(No help available)

### downforeveryone

(No help available)

### identify

(No help available)

### joker

(No help available)

### hangman

(No help available)

### fortune

(No help available)

### Admin

Admin handler -- handles admins, of course.

### Antispam Kicker

Kicks those who spam prefixed bot commands.

### Antispam Lister

List those who spam prefixed bot commands.

### Admin auth checker

Tells you if you are logged into the bot or not. (Admins only)

### 8ball

The Magic 8ball has all the answers!

Usage: `!8ball [question? <question? <...>>]`

### Random Attacker

Attacks a user with a random attack.

Usage: `!attack <nick or phrase>`; `<nick or phrase>` may be omitted for a random attack on a random nick.

### Auto OP

Automatically ops nicks upon join.

Usage: `!autoop [on|off]` -- turns autoop on or off. (Admins only)

### Auto Voice

Automatically voices nicks upon join.

Usage: `!autovoice [on|off]` -- turns autovoice on or off. (Admins only)

### Booru

Generates a handy link to a *booru search

Usage: `!booru <selector> <comma-separated list of tags>`; use `!booru` to get a list of tags.

### Botinfo

Notices you information about me.

Usage: `![botnick]`

### Decider

Helps you decide on things.

Usage: `!decide [a list of items separated by ", ", ", or", or " or "]`; Usage: `!coin`; Usage: `!rand [x] [y]`

### Delayed Rejoin

If the bot is kicked, it will attempt to rejoin after 10 seconds by default.

### Dicebox

Dicebox -- Uses standard dice notation.

Usage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)

### Jargon File

Gets the entry from the Jargon File.

Usage: `!jargon <entry>`

### Auto Notice

Notices nicks upon join.

Usage: `!hello` to replay entry notice.

### Kickban

Various commands used for kickbanning users.

Usage: `!moon [nick]` -- kicks the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.

Usage: `!sun [nick]` -- Kickbans the selected user [MLP-themed]

Usage: `!banana [nick]` -- Kicks too. Don't ask.

Usage: `!crp [nick]` -- Also kicks too. Don't ask, as well.

Usage: `!fus [nick]` -- I really need to come up with a better solution for this.

### QDB

Pulls a quote from a QDB.

`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.

### Ping

Pings you or a target via CTCP, and reports the number of milliseconds on recieving a response.

Usage: `!ping <nick>`

### Private toolbox

Bot administrator-only private commands.

Usage: n/a

### Rainbow

Rainbowificates your text.

Usage: `!rainbow [text]`.

Usage: `eyerape [text]`.

### Remote admin

Relays certain messages to logged-in admins.

### Russian Roulette

In Soviet Russia, boolet shoots YOU!

Usage: !rr <nick>

### Ryder

Beat PunchBeef! Blast Thickneck! Big McLargehuge!

Usage: `!ryder`

### Silly

You know, silly stuff.

### Toolbox

Bot administrator-only private commands.

Usage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;

### Twitter

Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.

Usage: `!tw<itter> [params[:username]] <info>`

### Urban Dictionary

Gets the first entry for an entry on UrbanDictionary.

Usage: `!urban <entry>`

### Weather

Grabs the current weather from WeatherUnderground.

Usage: `!weather [query]`

Author information
------------------
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net