require 'active_support'
require 'active_support/core_ext'
require 'time'

module Cinch
  module Helpers
    module NaturalLanguage

      def time_difference(from_time, to_time, params={})
        params = {
          acro: false,
          years: true,
          months: true,
          days: true,
          hours: true,
          minutes: true,
          seconds: true
        }.merge(params)
        # TODO: cite the source of the method
        # TODO: Move this function to a separate file in ../_ext/ and have it a method of the Date class with an argument of "to_time".
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_seconds = ((to_time - from_time).abs).round
        components = []
        
        parts = []
          parts << "year" if params[:years]
          parts << "month" if params[:months]
          parts << "day" if params[:days]
          parts << "hour" if params[:hours]
          parts << "minute" if params[:minutes]
          parts << "second" if params[:seconds]

    		parts.map do |interval|
    			distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
    			delta = (distance_in_seconds / 1.send(interval)).floor
    			delta -= 1 if from_time + delta.send(interval) > to_time
    			from_time += delta.send(interval)
          if params[:acro]
            components << "#{delta}#{interval[0].downcase}" if delta > 0
          else
            components << "#{delta} #{delta > 1 ? interval.pluralize : interval}" if delta > 0
          end
        end
        if params[:acro]
          components.join(" ")
        else
          components.to_sentence
        end
      end
      alias :time_diff_in_natural_language :time_difference
      
    end
  end
end