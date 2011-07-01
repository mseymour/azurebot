# -*- coding: UTF-8 -*-

require 'cinch'
require 'barometer'
require_relative '../_ext/blank.rb'
		
class Weather
  include Cinch::Plugin
	
	match %r{weather (.+)}
	
	def initialize(*args)
		super
		Barometer.config = { 1 => [:google, :wunderground] }
	end
	
	def current_weather! ( params={} )
    query = params[:query]||"Halifax, Nova Scotia"
    modifier = params[:modifier]||:default;
    
		return unless !query.blank?
		barometer = Barometer.new(query)
		return unless !barometer.success
		w = barometer.measure;
		
		template = "Current weather for %<location>s: %<condition>s, %<temperature>s, dew point: %<dew_point>s, humidity: %<humidity>s, wind: %<wind>s, visibility: %<visibility>s, sunrise/set: %<sunrise>s, %<sunset>s."
		
		case modifier
			when :default
				template % {
					:location => w.measurements[0].query.split.map(&:capitalize).join(" "),
					:condition => w.current.condition,
					:temperature => "#{w.temperature.c}°C",
					:dew_point => "#{w.dew_point.c}°C",
					:humidity => w.current.humidity,
					:wind => w.wind,
					:visibility => w.visibility,
					:sunrise => w.measurements[1].current.sun.rise,
					:sunset => w.measurements[1].current.sun.set }
			when "-f"
				template % {
					:location => w.measurements[0].query.split.map(&:capitalize).join(" "),
					:condition => w.current.condition,
					:temperature => "#{w.temperature.to_s.sub(/\s/,'°')}",
					:dew_point => "#{w.dew_point.to_s.sub(/\s/,'°')}",
					:humidity => w.current.humidity,
					:wind => w.wind,
					:visibility => w.visibility,
					:sunrise => w.measurements[1].current.sun.rise,
					:sunset => w.measurements[1].current.sun.set }
			end

	end
	def execute (m, query = nil)
		args = query != nil ? query.split(" ") : [nil, nil];
		if args[-1] =~ /-\w/
			m.reply current_weather!(:query => args[0..-2].join(" "), :modifier => args[-1]);
		else
			m.reply current_weather!(:query => args.join(" "));
		end
	end

end