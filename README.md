Azurebot
========

Azurebot is a Ruby-based IRC bot that uses the [Cinch IRC bot-building framework](https://github.com/cinchrb/cinch).

(Please note that this readme is still very much still being written. And probably will never get fully finished.)

Gems/requires used in various plugins
-------------------------------------
- active_support
- open-uri
- json
- nokogiri
- cgi
- yaml

### Gems/requires for specific plugins
#### ./lib/plugins/time_ban.rb
- redis

#### ./lib/plugins/twitter.rb
- twitter ~>2.0.2

#### ./lib/plugins/uptime.rb (may be removed)
- ruby-wmi
- socket

#### ./lib/plugins/weather.rb
- barometer

#### ./lib/plugins/botinfo.rb
- [tag_formatter](https://github.com/mseymour/tag_formatter) (read the readme!)

Configuration
=============
NOTE: Things may change a lot between this writing (2012/03/15) and when this is read.

### Admin password
To set the bot admin password (`/msg azurebot login <password>`), generate a SHA256 hash from the password that you want, and then save it under `./config/admin-password`.

All plugins that use the Admin command functionality already have the config assigned to them in the bootstrap script (`cinch.rb`).

### Setting up Twitter OAuth

If you already have keys set up, just copy them into a YAML file under "`./config/twitter_oauth.yaml`" with the following structure:

		---
		!ruby/sym consumer_key: KEY
		!ruby/sym consumer_secret: KEY
		!ruby/sym oauth_token: KEY
		!ruby/sym oauth_token_secret: KEY

### Setting per-channel on-join notices
To set up an on-join notice, make sure that the config is set up to have a folder and a file extension. Example:

		c.plugins.options[Plugins::JoinNotice] = { greetings: File.dirname(__FILE__) + '/config/greetings/freenode/', filext: '.txt' }

Where "`freenode`" is replaced with whatever network that the bot is on (for organizational purposes.)

For instance, if I want to have an on-join notice for `#cinch-bots`, I would just save a text file named "`./config/greetings/freenode/#cinch-bots.txt`".

Authors
=======
Mark Seymour (<mark.seymour.ns@gmail.com>)