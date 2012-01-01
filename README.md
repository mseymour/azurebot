Azurebot
========

A Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github")

Plugins
-------

### Admin (`Plugins::AdminHandler`)

Admin handler -- handles admins, of course.

### Antispam Kicker (`Plugins::AntiSpam::Kicker`)

Kicks those who spam prefixed bot commands.

### Antispam Lister (`Plugins::AntiSpam::Lister`)

List those who spam prefixed bot commands.

### Admin auth checker (`Plugins::Authtest`)

Tells you if you are logged into the bot or not. (Admins only)

### 8ball (`Plugins::Eightball`)

The Magic 8ball has all the answers!

Usage: `!8ball [question? <question? <...>>]`

### Random Attacker (`Plugins::Attack`)

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

### Botinfo (`Plugins::BotInfo`)

Notices you information about me.

Usage: `![botnick]`

### Decider (`Plugins::Decide`)

Helps you decide on things.

Usage: `!decide [a list of items separated by ", ", ", or", or " or "]`; Usage: `!coin`; Usage: `!rand [x] [y]`

### Delayed Rejoin (`Plugins::DelayedRejoin`)

If the bot is kicked, it will attempt to rejoin after 10 seconds by default.

### Dicebox (`Plugins::Dice`)

Dicebox -- Uses standard dice notation.

Usage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)

### DJ Info (`Plugins::DJInfo`)

Spams the channel with DJ contact information.

Usage: `!dj <dj_name>`

### Jargon File (`Plugins::JargonFile`)

Gets the entry from the Jargon File.

Usage: `!jargon <entry>`

### Auto Notice (`Plugins::JoinNotice`)

Notices nicks upon join.

Usage: `!hello` to replay entry notice.

### Kickban (`Plugins::Kickban`)

Various commands used for kickbanning users.

Usage: `!moon [nick]` -- kicks the selected user with a My Little Pony: Friendship Is Magic-themed kick reason.

Usage: `!sun [nick]` -- Kickbans the selected user [MLP-themed]

Usage: `!banana [nick]` -- Kicks too. Don't ask.

Usage: `!crp [nick]` -- Also kicks too. Don't ask, as well.

Usage: `!fus [nick]` -- I really need to come up with a better solution for this.

### QDB (`Plugins::MultiQDB`)

Pulls a quote from a QDB.

`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.

### Ping (`Plugins::Ping`)

Pings you or a target via CTCP, and reports the number of milliseconds on recieving a response.

Usage: `!ping <nick>`

### Private toolbox (`Plugins::PrivToolbox`)

Bot administrator-only private commands.

Usage: n/a

### Rainbow (`Plugins::Rainbow`)

Rainbowificates your text.

Usage: `!rainbow [text]`.

Usage: `eyerape [text]`.

### Remote admin (`Plugins::RemoteAdmin`)

Relays certain messages to logged-in admins.

### Russian Roulette (`Plugins::RussianRoulette`)

In Soviet Russia, boolet shoots YOU!

Usage: !rr <nick>

### Ryder (`Plugins::Ryder`)

Beat PunchBeef! Blast Thickneck! Big McLargehuge!

Usage: `!ryder`

### Silly (`Plugins::Silly`)

You know, silly stuff.

### Toolbox (`Plugins::Toolbox`)

Bot administrator-only private commands.

Usage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`; `~nick [newnick]`; `~opadmin`;

### Twitter (`Plugins::Twitter::Client`)

Access Twitter from the comfort of your IRC client!

Usage: `!tw <username><+D> - Gets the latest tweet of the specified user, or the tweet 'D' tweets back, between 1 and 20.

       `!tw #[id]` - Gets the tweet at the specified ID

       `?tw [username]` - Gets the specified user's Twitter profile

       `?ts [term]` - Searches for three of the most recent tweets regarding the specified query

       Shorthand: `@[username]<+D>`, @#[id]

### Urban Dictionary (`Plugins::UrbanDictionary`)

Gets the first entry for an entry on UrbanDictionary.

Usage: `!urban <entry>`

### Weather (`Plugins::Weather`)

Grabs the current weather from WeatherUnderground.

Usage: `!weather [query]`

Author information
------------------
* Mark Seymour ('Azure')
* Email: <mark.seymour.ns@gmail.com>
* WWW: <http://lain.rustedlogic.net/>
* IRC: #shakesoda @ irc.freenode.net