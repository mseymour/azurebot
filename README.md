Azurebot
========

Azurebot is a Ruby-based IRC bot that uses the [Cinch IRC bot-building framework](https://github.com/cinchrb/cinch).

(Please note that this readme is still very much still being written. And probably will never get fully finished.)

Gems/requires used in various plugins
-------------------------------------
- [active_support](https://rubygems.org/gems/active_support)
- [open-uri](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html)
- [json](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/json/rdoc/JSON.html)
- [nokogiri](https://rubygems.org/gems/nokogiri)
- [cgi](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/cgi/rdoc/CGI.html)
- [yaml](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/yaml/rdoc/YAML.html)

### Gems/requires for specific plugins
#### ./lib/plugins/time_ban.rb
- [redis](https://rubygems.org/gems/redis)

#### ./lib/plugins/twitter.rb
- [twitter](https://rubygems.org/gems/twitter) ~>2.0.2

#### ./lib/plugins/uptime.rb (may be removed)
- [ruby-wmi](https://rubygems.org/gems/ruby-wmi)
- [socket](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/socket/rdoc/Socket.html)

#### ./lib/plugins/weather.rb
- [barometer](https://rubygems.org/gems/barometer)

#### ./lib/plugins/botinfo.rb
- [tag_formatter](https://rubygems.org/gems/tag_formatter)

#### ./lib/plugins/define.rb
- [insensitive_hash](https://rubygems.org/gems/insensitive_hash)

Configuration
=============
NOTE: Things may change a lot between this writing (2012/05/01) and when this is read.

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