# -*- coding: UTF-8 -*-

# azTwitter1 & 2 - using hpricot
# azTwitter3 - using Twitter4r
# azTwitter4 - using Grackle
# Twitter5 - using Twitter (https://github.com/jnunemaker/twitter)

gem 'twitter', '>= 2.0.0'
require 'twitter'
require 'date'
require 'yaml'
require 'active_support/core_ext/object/blank'
require 'obj_ext/string'

module Plugins
  class Twitter5
    
    # Defining errors
    class Error < StandardError
      class Protected < Error; end
      class No_Tweets < Error; end
    end
    
    include Cinch::Plugin
    set(
      plugin_name: "Twitter", 
      help: "Gets the current tweet of the user specified. If it is blank, it will return Twitter's official account instead.\nUsage: `!tw<itter> [params[:username]] <info>`", 
      required_options: [:access_keys])
    
    # Class variables
    VERSION = "5.0.0b2"

    @@error_template = "![bc10]Fail Whale sighted!![bc] · %<message>s"
    
    def initialize (*args)
      super;
      keys = YAML::load_file(config[:access_keys])
      Twitter.configure do |c|
        c.consumer_key = keys["consumer_key"]
        c.consumer_secret = keys["consumer_secret"]
        c.oauth_token = keys["oauth_token"]
        c.oauth_token_secret = keys["oauth_token_secret"]
      end
    end
    
    def twitterproc params={}
      params = {
        username: "twitter",
        modifier: :default
      }.merge(params)
      
      begin
        user_timeline = Twitter.user_timeline(params[:username], :include_rts => true)
        raise Error::No_Tweets if user_timeline.blank?;
        raise Error::Protected if user_timeline.first.user.protected;
      
        case params[:modifier]
          when :default
            
            # Move to separate def later.
            the_tweet = user_timeline.first;
            
            # Constructing output!
            screen_name = "[#{the_tweet.user.screen_name}]";
            
            tweet_text = format_tweet("@", "10", format_tweet("#", "10", the_tweet.text.irc_strip_colors.gsub(/(\r|\n)/," ")))
            
            metadata = [];
            metadata << (the_tweet.user.geo_enabled == true && the_tweet.place != nil ? "from #{the_tweet.place.full_name}" : "");
            metadata << "at #{the_tweet.created_at.strftime("%F %R")}";
            metadata << "via #{the_tweet.source.gsub(/<\/?[^>]*>/, "")}";
            metadata << "#{the_tweet.user.verified == true ? "![c10]✔![c] " : ""}"
            
            user_uri = "![u]http://twitter.com/#{the_tweet.user.screen_name}![u]";
            File.open("#{File.expand_path("~")}/tweet.yaml", 'w') {|f| f.write(YAML::dump(the_tweet)) }
            in_reply_to = (the_tweet.attrs['in_reply_to_status_id'] != nil ? "![c14]in reply to![c] ![u]http://twitter.com/#{the_tweet.attrs['in_reply_to_screen_name']}/status/#{the_tweet.attrs['in_reply_to_status_id']}![u]" : "");
            
            metadata = metadata.reject(&:empty?).join(' ');
            urls = [user_uri, in_reply_to].reject(&:empty?).join(' ');
            
            "![c10]%<screen_name>s![c] %<tweet_text>s ![c14](%<metadata>s)![c] %<urls>s" % {:screen_name => screen_name, :tweet_text => tweet_text, :metadata => metadata, :urls => urls};
            
          when "info"
            the_user = Twitter.user(params[:username]);
          
            lines = [];
            lines << "![c10,01]@![b]#{the_user.screen_name}![b]#{the_user.verified == true ? "![c01,10]✔![c]" : ""} - #{the_user.name} ![c14](http://twitter.com/#{the_user.screen_name}#{!the_user.url.blank? ? ", #{the_user.url}" : ""})";
            lines << (!the_user.description.blank? ? "![c10]#{the_user.description}" : "");
            lines << (!the_user.location.blank? ? "Is from ![bc10]#{the_user.location}![bc]." : "");
            lines << "They have ![bc10]#{commas(the_user.statuses_count)}![bc] statuses, ![bc10]#{commas(the_user.followers_count)}![bc] followers, ![bc10]#{commas(the_user.friends_count)}![bc] friends, and is on ![bc10]#{commas(the_user.listed_count)}![bc] lists.";
            lines << "![b]Their latest tweet:![b] #{format_tweet("@", "10", format_tweet("#", "10", the_user.status.text.irc_strip_colors.gsub(/(\r|\n)/," ")))}";
            
            lines = lines.reject(&:empty?).join("\n");
            
            lines;
        end
      
      rescue Twitter::Error => twerr
        @bot.debug(twerr.message);
        case twerr
          when Twitter::Error::BadRequest
            @@error_template % {:message => "Badrequest (rate limit exceeded? Warn Azure when this occurs.)"}
          when Twitter::Error::Unauthorized
            @@error_template % {:message => "#{params[:username]}'s account seems to be protected or suspended."}
          when Twitter::Error::Forbidden
            # stupid coding (raise in a rescue block) was here — 2011-06-11 1:27am
            if twerr.message =~ /\bsuspended\b/i
              @@error_template % {:message => "#{params[:username]} has been suspended!"}
            else
              @@error_template % {:message => "Forbidden (update limit exceeded? Warn Azure when this occurs."}
            end
          when Twitter::Error::NotFound
            @@error_template % {:message => "The account \"#{params[:username]}\" seems to be not found!"}
          when Twitter::Error::NotAcceptable
            @@error_template % {:message => "An invalid format is specified in the search request."}
          when Twitter::Error::EnhanceYourCalm
            @@error_template % {:message => "Enhance your calm. #{@bot.nick} is being rate limited."}
          when Twitter::Error::InternalServerError
            @@error_template % {:message => "Something seems to be broken! Please try again in a minute."}
          when Twitter::Error::BadGateway
            @@error_template % {:message => "Twitter seems to be down, or is being upgraded. Please try again in a minute."}
          when Twitter::Error::ServiceUnavailable
            @@error_template % {:message => "Twitter is currently under heavy load. Please try again in a few minutes, and hopefully it'll clear up."}
        end
      rescue Twitter5::Error => twerr
        case twerr
          when Twitter5::Error::Protected
            @@error_template % {:message => "#{params[:username]}'s tweets are protected!"}
          when Twitter5::Error::No_Tweets
            @@error_template % {:message => "#{params[:username]} is lame for creating an account and not tweeting yet!"}
        end
      end
    end
    
    def format_tweet(tag_prefix, irc_colour, tweet)
      tweet.gsub(/(#{tag_prefix})(\w+)/i,"![c#{irc_colour.to_s.rjust(2,"0")}]\\1![c]\\2")
    end
    alias fmtt format_tweet
    
  	def commas(number, delimiter = ',')
  		number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse;
  	end

    match %r/tw$/
    match %r/twitter$/
    match %r/tw (.+)*/
    match %r/twitter (.+)*/
    def execute(m, words = nil)
  		args = words != nil ? words.split(" ") : [nil, nil];
      
      twitter_options = {}
      twitter_options[:username] = args[0] if !args[0].nil?
      twitter_options[:modifier] = args[1] if !args[1].nil?

      m.reply twitterproc(twitter_options).irc_colorize, false;
    end

  end
end