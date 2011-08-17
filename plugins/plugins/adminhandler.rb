# -*- coding: utf-8 -*-
require_relative '../modules/helpers/table_format'

class AdminHandler
	include Cinch::Plugin

	set(
		plugin_name: "admin",
		help: "Admin handler -- handles admins, of course.",
		required_options: [:admins],
		react_on: :private)

	def login user, password
		return "You are already here, #{user.nick}." unless !config[:admins].logged_in? user.mask
		result = config[:admins].login! user.mask, password
		if result
			"Welcome back, #{user.nick}."
		else
			"#{user.nick}, your password is incorrect."
		end
	end

	match /^login (.+)/, method: :execute_login, use_prefix: false
	def execute_login m, password
		m.user.msg login(m.user, password), true
	end

	match /^logout/, method: :execute_logout, use_prefix: false
	def execute_logout m
		return unless config[:admins].logged_in? m.user.mask
		config[:admins].logout! m.user.mask
		m.user.msg "Sayonara, #{m.user.nick}.", true
	end

	match /^admins/, method: :execute_admins, use_prefix: false
	def execute_admins m
		return unless config[:admins].logged_in? m.user.mask
		m.user.msg Helpers::table_format(config[:admins].masks, regexp: /(?:(.+)!)?(.+)/, gutter: 1, justify: [:right,:left], headers: ["nick","username+host"]), true
	end

	listen_to :nick, method: :listen_nick
	def listen_nick m
		return unless config[:admins].logged_in?(m.user.mask("#{m.user.last_nick}!%u@%h"))
		config[:admins].update m.user.mask("#{m.user.last_nick}!%u@%h"), m.user.mask
		@bot.debug "Updated hostmask. (`#{m.user.mask("#{m.user.last_nick}!%u@%h")}` -> `#{m.user.mask}`)"
	end

	listen_to :quit, method: :listen_quit
	def listen_quit m
		#outgoing_mask = "#{m.user.nick}!#{m.user.data[:user]}@#{m.user.data[:host]}"
		return unless config[:admins].logged_in?(m.prefix)
		config[:admins].logout! m.prefix #change back to m.user.mask once fixed in cinch
		@bot.debug "#{m.prefix} has been automagically logged out."
	end

end