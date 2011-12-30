# coding: utf-8

gem 'twitter', '~>2.0.2'
require 'twitter'
require 'yaml'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/conversions'
require_relative 'twitter/tweet_handler'

module Plugins
  module Twitter
    class Client
      include Cinch::Plugin
      include TweetHandler

    set(
      plugin_name: "Twitter", 
      help: "Access Twitter from the comfort of your IRC client!\nUsage: `!tw <username><+D> - Gets the latest tweet of the specified user, or the tweet 'D' tweets back, between 1 and 20.\n       `!tw #[id]` - Gets the tweet at the specified ID\n       `?tw [username]` - Gets the specified user's Twitter profile\n       `?ts [term]` - Searches for three of the most recent tweets regarding the specified query\n       Shorthand: `@[username]<+D>`, @#[id]", 
      required_options: [:access_keys])

      def initialize (*args)
        super
        keys = YAML::load_file(config[:access_keys])
        ::Twitter.configure do |c|
          c.consumer_key = keys["consumer_key"]
          c.consumer_secret = keys["consumer_secret"]
          c.oauth_token = keys["oauth_token"]
          c.oauth_token_secret = keys["oauth_token_secret"]
        end
      end

      match /tw$/, method: :execute_tweet
      match /tw (\w+)(?:\+(\d+))?$/, method: :execute_tweet
      match /^@(\w+)(?:\+(\d+))?$/, method: :execute_tweet, use_prefix: false
      def execute_tweet m, username = nil, nth_tweet = nil
        options = {}
        options[:username] = username unless username.nil?
        options[:nth_tweet] = nth_tweet unless nth_tweet.nil?
        m.reply tweet_by_username(options)
      end

      match /tw #(\d+)$/, method: :execute_id
      match /^@#(\d+)$/, method: :execute_id, use_prefix: false
      def execute_id m, id
        m.reply tweet_by_id(id: id)
      end

      match /\?tw (\w+)$/, method: :execute_info, use_prefix: false
      def execute_info m, username
        m.reply tweep_info(username: username)
      end

      match /\?ts (.+)$/, method: :execute_search, use_prefix: false
      def execute_search m, term
        m.reply search_by_term(term: term)
      end

      listen_to :channel, method: :listen_channel
      def listen_channel m
        urlregexp = /(https?:\/\/twitter.com\/(?:#!\/)?(\w+)(?:\/status\/(\d+))?)/i
        return unless m.message =~ urlregexp
        urls = m.message.scan(urlregexp)
        urls.each {|url|
          username, id = url[1..2]
          if id.nil?
            m.reply tweet_by_username(username: username)
          else
            m.reply tweet_by_id(id: id)
          end
        }
      end

    end
  end
end