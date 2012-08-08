# -*- coding: utf-8 -*-

require 'geocoder'
require_relative 'weather/wx'
require 'active_support/core_ext/object/blank'

module Cinch
  module Plugins
    class Weather
      include Cinch::Plugin
      set(
        plugin_name: "Weather",
        help: "Grabs the current weather and forecast from WeatherUnderground.\nUsage: `!weather <-si> [query]`\nUsage: `!forecast <-si> [query]\nSwitches: `s` -- Simple conditions; `i` -- Imperial measurements\nShorthand for !weather: !wx",
        required_options: [:api_key])

      @@mapping = {
        metric: {t: "c", d: "km", s: "kph", p: %w{metric mm}},
        imperial: {t: "f", d: "mi", s: "mph", p: %w{in in}}
      }

      @@moon_phases = ['New Moon', 'Waxing Crescent', 'First Quarter', 'Waxing Gibbious', 'Full Moon', 'Waning Gibbious', 'Last Quarter', 'Waning Crescent']

      @@unicon = {
        chanceflurries:'❄',
        chancerain:'☂',
        chancesleet:'☂❄',
        chancesnow:'☃',
        chancetstorms:'☈',
        clear:'☀',
        cloudy:'☁',
        flurries:'❄',
        fog:'☁',
        hazy:'☁',
        mostlycloudy:'☁',
        mostlysunny:'☀',
        partlycloudy:'☁',
        partlysunny:'☀',
        sleet:'☂❄',
        rain:'☂',
        snow:'☃',
        sunny:'☀',
        tstorms:'☈',
        unknown:''
      }

      match /w(?:eather|x)(?:(?> -)([[:alpha:]]+))? (.+)/, method: :execute_weather
      def execute_weather(m, switches, query)
        # Switch handling
        metric, simple = true, false
        switches.chars {|c|
          case c.intern
          when :i then metric = false
          when :s then simple = true
          end
        } unless switches.nil?

        # Fetching weather conditions!
        geo = Geocoder.search(query)
        if !geo.empty?
          if geo.count == 1
            m.reply fetch_conditions(geo.first.coordinates * ',', metric, simple)
          else
            list = geo.each_with_object([]) {|addr, memo| memo << addr.formatted_address }
            m.user.notice "#{Format(:green,:bold,"Whoops!")} · It appears that your search was a bit too broad. Did you mean: #{list * '; '}"
          end
        else
          m.user.notice "#{Format(:green,:bold,"Whoops!")} · Your search has not returned any results."
        end
      rescue => e
        errmsg = e.message.kind_of?(Hashie::Mash) ? e.message.description : e.message.to_s
        m.user.notice "#{Format(:red,:bold,"Uhoh!")} · #{errmsg}"
      end

      match /forecast(?:(?> -)([[:alpha:]]+))? (.+)/, method: :execute_forecast
      def execute_forecast(m, switches, query)
        # Switch handling
        metric = true
        switches.chars {|c|
          case c.intern
          when :i then metric = false
          end
        } unless switches.nil?

        # Fetching weather conditions!
        geo = Geocoder.search(query)
        if !geo.empty?
          if geo.count == 1
            m.user.msg fetch_forecast(geo.first.coordinates * ',', metric)
          else
            list = geo.each_with_object([]) {|addr, memo| memo << addr.formatted_address }
            m.user.notice "#{Format(:green,:bold,"Whoops!")} · It appears that your search was a bit too broad. Did you mean: #{list * '; '}"
          end
        else
          m.user.notice "#{Format(:green,:bold,"Whoops!")} · Your search has not returned any results."
        end
      rescue => e
        errmsg = e.message.respond_to?(:description) ? e.message.description : e.message.to_s
        m.user.notice "#{Format(:red,:bold,"Uhoh!")} · #{errmsg}"
      end

      private

      def fetch_forecast(query, is_metric, count=-1)
        result = Cinch::Plugins::Weather::Wx.new(config[:api_key]).get(query, :forecast, :geolookup)
        place = [result.location.city, result.location.state]
        "Forecast for #{place * ', '}:\n" + result.forecast.txt_forecast.forecastday[0..count].each_with_object([]) {|f, a|
          a << "#{f.title}: #{is_metric ? f.fcttext_metric : f.fcttext}"
        } * "\n"
      end

      def fetch_conditions(query, is_metric, is_minimal)
        units = is_metric ? @@mapping[:metric] : @@mapping[:imperial]

        result = Cinch::Plugins::Weather::Wx.new(config[:api_key]).get(query, :conditions, :almanac, :astronomy)
        raise StandardError, result.response.error if result.response.error

        co = result.current_observation
        al = result.almanac
        as = result.moon_phase
        degrees = '°' << units[:t].upcase

        outside = []
        outside << co.weather + " #{@@unicon[co.icon.intern]}" unless co.weather.blank?
        outside << "#{co['temp_' << units[:t]]}#{degrees}"
        outside << "feels like #{co['feelslike_' << units[:t]]}#{degrees}" unless co['feelslike_' << units[:t]].to_s.eql?(co['temp_' << units[:t]].to_s)
        conditions = {
          "High/Low" => hilo(al.temp_high.normal[units[:t].upcase] << degrees,
                             al.temp_low.normal[units[:t].upcase] << degrees),
          "Dew point" => "#{co['dewpoint_' << units[:t]]}#{degrees}",
          "Humidity" => co.relative_humidity,
          "Precip" => precip(co['precip_1hr_' << units[:p][0]]+" #{units[:p][1]}",
                             co['precip_today_' << units[:p][0]]+" #{units[:p][1]}"),
          "Wind" => wind(co.wind_dir, 
                         "#{co['wind_' << units[:s]]} #{units[:s]}", 
                         "#{co['wind_gust_' << units[:s]]} #{units[:s]}"),
          "Wind chill" => "#{co['windchill_' << units[:t]]}#{degrees}",
          "Heat index" => "#{co['heat_index_' << units[:t]]}#{degrees}",
          "Pressure" => "#{(co.pressure_mb.to_f / 10.00).round(2)} kPa #{pressure_trend(co.pressure_trend)}",
          "Visibility" => "#{co['visibility_' << units[:d]]} #{units[:d]}",
          "UV Index" => (uv_string(co.UV) + " (#{co.UV})" unless co.UV.to_f < 0),
          "Sunrise/set" => ["#{DateTime.parse([as.sunrise.hour,as.sunrise.minute] * ":").strftime("%-l:%M%P")}",
                            "#{DateTime.parse([as.sunset.hour,as.sunrise.minute] * ":").strftime("%-l:%M%P")}"] * ", ",
          "Moon" => @@moon_phases[((as.ageOfMoon.to_i / 30.00) * 8.00).floor]
        }

        minimal_data = ["Wind","Visibility","UV Index","Sunrise/set"]

        conditions.reject! {|k,v| v.blank? || v.match(/^NA|^N\/A/i) || (is_minimal && !minimal_data.include?(k)) }
        collected = conditions.collect {|k,v| "#{k}: #{v}" }

        head = if !is_minimal
          "Current weather for %s (%s) at %s:" % [
            co.display_location.full,
            co.station_id,
            DateTime.parse(co.local_time_rfc822).strftime("%b %-d, %Y, %-l:%M%P") ]
        else
          "Current weather for #{co.display_location.full}:"
        end

        foot = is_minimal ? co.forecast_url : "The full forecast can be viewed at #{co.forecast_url}"

        [head,[*outside,collected.join("; ")].join(", ") << '.',foot] * (is_minimal ? " " : "\n")
      end

      def pressure_trend(pt)
        case pt.to_s
        when "+" then "rising"
        when "0" then "steady"
        when "-" then "falling"
        else
          ""
        end
      end

      def precip(onehour, today)
        return "" if [onehour, today].all? {|i| i.to_f <= 1 }
        parts = []
        parts << "#{onehour} in the past hour" unless onehour.to_f < 1
        parts << "#{today} today" unless today.to_f < 1
        parts.join(", and ")
      end

      def hilo(hi, lo)
        return "" if [hi, lo].all? {|i| i[0..-3].blank? } # Omits last two chars (°F/C)
        parts = []
        parts << hi
        parts << lo
        parts.join(", ")
      end

      def wind(dir, speed, gust)
        return "" if [speed, gust].all? {|i| i.to_f <= 0 }
        parts = []
        parts << "#{dir} at #{speed}" unless 
        parts << "gusting to #{gust}" if gust.to_f > 0
        parts.join(", ")
      end

      def uv_string(uv)
        case uv.to_i
        when 0..2 then "Low" #Format(:green,"Low")
        when 3..5 then "Moderate" #Format(:yellow,"Moderate")
        when 6..7 then "High" #Format(:orange,"High")
        when 8..10 then "Very High" #Format(:red,"Very High")
        when 11..Float::INFINITY then "Extreme" #Format(:violet,"Extreme")
        else
          uv
        end
      end

    end
  end
end
