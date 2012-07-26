# -*- coding: utf-8 -*-
Encoding.default_internal = "UTF-8"
Encoding.default_external = "UTF-8"

require 'barometer'
require 'active_support/core_ext/object/blank'

module Plugins
  class Weather
    include Cinch::Plugin
      set(
        plugin_name: "Weather",
        help: "Grabs the current weather from WeatherUnderground.\nUsage: `!weather [query]`")

    @@unicon = {
    :clear => ["☾","clear"],
    :cloudy => ["☁","cloudy"],
    :flurries => ["☃","flurries"],
    :fog => ["☁","fog"],
    :hazy => ["☁","hazy"],
    :mostlycloudy => ["☁", "mostly cloudy"],
    :mostlysunny => ["☀", "mostly sunny"],
    :partlycloudy => ["☁☀", "partly cloudy"],
    :partlysunny => ["☀☁", "partly sunny"],
    :rain => ["☂", "rain"],
    :sleet => ["☂☃", "sleet"],
    :snow => ["☃", "snow"],
    :sunny => ["☀", "sunny"],
    :tstorms => ["☈", "thunderstorms"],
    :unknown => ["☄", "???"]
    }
    def initialize(*args)
      super
      Barometer.config = { 1 => [:wunderground] }
    end

    def current_weather!(params={})
      query = params[:query]||"Halifax, Nova Scotia"
      modifier = params[:modifier]||:default;
      return unless !query.blank?
      barometer = Barometer.new(query)
      return unless !barometer.success
      m = barometer.measure.measurements[0];
      w = m.current;

      out = []
      out << "#{!w.condition.nil? ? w.condition : @@unicon[w.icon.to_sym][1].capitalize} #{@@unicon[w.icon.to_sym][0]}, #{w.temperature.c}°C (#{w.temperature.f}°F)"
      out << "Dew point: #{w.dew_point.c}°C (#{w.dew_point.f}°F)" if !w.dew_point.nil?
      out << "Humidity: #{w.humidity}%" if !w.humidity.nil?
      out << "Heat index: #{w.heat_index.c}°C (#{w.heat_index.f}°F)" if !w.heat_index.nil?
      out << "Pressure: #{(w.pressure.mb * 0.1).round(3)} kPa" if !w.pressure.nil?
      out << "Wind speed: #{w.wind.kph} km/h (#{w.wind.mph} mph), #{w.wind.degrees}° #{w.wind.direction}" if !w.wind.nil?
      out << "Wind chill: #{w.wind_chill.c}°C (#{w.wind_chill.f}°F)" if !w.wind_chill.nil?
      out << "Visibility: #{w.visibility.kilometers || w.visibility.km} km (#{w.visibility.miles || w.visibility.m} mi)" if !w.visibility.nil?
      out << "Sunrise/set: #{w.sun.rise}, #{w.sun.set}" if !w.sun.nil?

      "Current weather for #{m.location.name || m.query} as of #{m.measured_at}: #{out.reject(&:blank?).join("; ")}."
    rescue => e
      "Uhoh! Something went wrong! #{e.message}"
    end

    match /weather (.+)/
    def execute(m, query = nil)
      args = query != nil ? query.split(" ") : [nil, nil];
      if args[-1] =~ /-\w/
        m.reply current_weather!(:query => args[0..-2].join(" "), :modifier => args[-1]);
      else
        m.reply current_weather!(:query => args.join(" "));
      end
    end
  end
end
