# Azurebot
## a Ruby-powered IRC bot using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at github")

- - -

## List of current commands available (subject to change depending on plugins loaded):

### Administrator-only commands:

#### Public and private:
* `~join [channel]`
* `~part <channel>`
* `~quit <message>`
* `~nick [nick]`

#### Private only:
* `say [channel] [message]`
* `act [channel] [message]`
* `cs [...]`
* `ns [...]`
* `hs [...]`

### "Core" commands:
* `!autoop <on|off>`
* `!autovoice <on|off>`
* `!c[ommands]`
* `!moon [nick]`

### "Fun" commands:
* `!attack <phrase>`
* `!decide [item1(, |, or | or )[item2(, |, or | or )[...]]]`
* `!dice [(standard dice notation)]`
* `!dongs <number>`
* `!fb (play|pause|pp|prev|next|rand|stop|np)`
* `!rainbow [string]`
* `!ryder`

### "Informative" commands:
* `!booru <<selector> tags>`
* `!azurebot` _(or whatever the bot's initial nick is)_
* `!dict <string>` _Unfinished/not working_
* `!jargon <string>`
* `!autogreet [on|off]`
* `!qdb [id]` _Currently only accesses (#shakesoda's)[irc://irc.freenode.net/shakesoda] QDB._
* `!request [request]` _Unfinished/unused_
* `!tw<itter> [username] <-info>`
* `!uptime` _unfinished_
* `!urban <string>`
* `!weather [place name] <-f>`

- - -

_Please note that the documentation may or may not be out of date from the contents of the repository, and that some plugins may or may not be usable._