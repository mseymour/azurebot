# coding: utf-8

require_relative 'formatter'
require_relative 'error_handler'

module Plugins
  module Twitter
    module TweetHandler
      include Formatter
      include ErrorHandler

      EXCEPTIONS = [::Twitter::Error, ErrorHandler::Warnings]

      # Handler methods

      def tweet_by_username params={}
        params = { username: "Twitter", nth_tweet: 0 }.merge(params)
        begin
          raise Warnings::TooManyTweets if params[:nth_tweet].to_i > 20
          timeline = ::Twitter.user_timeline params[:username], include_rts: true, count: params[:nth_tweet].to_i.succ
          raise Warnings::NoTweets if timeline.blank?
          tweet = timeline.last
          params[:username] = tweet.user.screen_name # For proper case.
          
          return "No tweets!" if timeline.blank?
          return "Protected!" if tweet.user.protected?
          
          format_tweet tweet # The fun starts here. If there is ever a problem, it'll bubble up here and be caught.

        rescue *EXCEPTIONS => ex
          handle_error ex, params[:username], @bot.nick
        end
      end

      def tweet_by_id params={}
        params = {id: 0 }.merge(params)
        begin
          tweet = ::Twitter.status params[:id]
          params[:username] = tweet.user.screen_name # For easy access.
          format_tweet tweet # If there is ever a problem, it'll bubble up here and be caught.
        rescue *EXCEPTIONS => ex
          handle_error ex, params[:username], @bot.nick
        end
      end

      def tweep_info params={}
        params = {username: "Twitter"}.merge(params)
        begin
          tweep = ::Twitter.user params[:username]
          format_tweep_info tweep
        rescue *EXCEPTIONS => ex
          handle_error ex, params[:username], @bot.nick
        end
      end

      def search_by_term params={}
        params = {term: "cat"}.merge(params)
        begin
          results = []
          ::Twitter.search(params[:term], rpp: 3, result_type: "recent").each {|status|
            params[:username] = status.from_user
            results << format_search(status)
          }
          results << "There are no results for \"#{params[:term]}\"." if results.empty?
          results.join("\n")
        rescue *EXCEPTIONS => ex
          handle_error ex, params[:username], @bot.nick
        end
      end

    end
  end
end