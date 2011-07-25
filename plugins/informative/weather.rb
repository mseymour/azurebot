# -*- coding: UTF-8 -*-
require 'barometer'
require_relative '../_ext/blank.rb'
		
class Weather
  include Cinch::Plugin
	help "!weather [query]"
	
	match %r{weather (.+)}

@@unicon = {
:clear => "☀☀☀",
:cloudy => "☁☁☁",
:flurries => "☃",
:fog => "☁",
:hazy => "☁",
:mostlycloudy => "☁",
:mostlysunny => "☀☀☁",
:partlycloudy => "☀☁",
:partlysunny => "☁☀",
:rain => "☂",
:sleet => "☂☃",
:snow => "☃☃☃",
:sunny => "☀☀",
:tstorms => "☁☈",
:unknown => "?"
}
	def initialize(*args)
		super
		Barometer.config = { 1 => [:google, :wunderground] }
	end
	
	def current_weather! ( params={} )
    query = params[:query]||"Halifax, Nova Scotia"
    modifier = params[:modifier]||:default;
    begin
			return unless !query.blank?
			barometer = Barometer.new(query)
			return unless !barometer.success
			w = barometer.measure;
			
			template = "Current weather for %<location>s: %<condition>s, %<temperature>s, dew point: %<dew_point>s, humidity: %<humidity>s, wind: %<wind>s, visibility: %<visibility>s, sunrise/set: %<sunrise>s, %<sunset>s."
					
					loc = w.measurements[0].query.split.map(&:capitalize).join(" ").split(",")
					loc[-1].upcase!
					loc = loc.join(",")
					
					template % {
						:location => loc,
						:condition => w.current.condition + " #{@@unicon[w.measurements[1].current.icon.to_sym]}" || "?",
						:temperature => "#{w.temperature.c}°C (#{w.temperature.to_s.sub(/\s/,'°')})",
						:dew_point => "#{w.dew_point.c}°C (#{w.dew_point.to_s.sub(/\s/,'°')})",
						:humidity => "#{w.current.humidity}%",
						:wind => w.wind,
						:visibility => w.visibility,
						:sunrise => w.measurements[1].current.sun.rise,
						:sunset => w.measurements[1].current.sun.set }
		rescue
			"script:#{$0} | errloc:#{$@[0]} | PID:#{$$}"
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