# coding: utf-8

module Plugins
  module Twitter
    module ErrorHandler

      class Warnings < StandardError
        class TooManyTweets < Warnings; end;
        class NoTweets < Warnings; end;
      end

      def handle_error ex, username, bot_nick
        params = {
          username: username,
          bot_nick: bot_nick
        }
        
      exceptions = { 
        ::Twitter::Error::BadRequest => "Bad request!",
        ::Twitter::Error::Unauthorized => "%<username>s's account seems to be protected.",
        ::Twitter::Error::Forbidden => "Suspended!",
        ::Twitter::Error::NotFound => "The account \"%<username>s\" seems to be not found!",
        ::Twitter::Error::NotAcceptable => "An invalid format is specified in the search request.",
        ::Twitter::Error::EnhanceYourCalm => "Enhance your calm. %<bot_nick>s is being rate limited.",
        ::Twitter::Error::InternalServerError => "Something seems to be broken! Please try again in a minute.",
        ::Twitter::Error::BadGateway => "Twitter seems to be down, or is being upgraded. Please try again in a minute.",
        ::Twitter::Error::ServiceUnavailable => "Twitter is currently under heavy load. Please try again in a few minutes, and hopefully it'll clear up.", 
        Warnings::TooManyTweets => "You cannot backtrack past 20 tweets.",
        Warnings::NoTweets => "%<username>s is lame for creating an account and not tweeting yet!"}

        "#{Format(:red,:bold,"Uhoh!")} · #{exceptions[ex.class]}" % params;
      end
    end
  end
end