require 'date'
require 'active_support/time'
require 'active_support/core_ext/date_time/conversions'

module Cinch
  module Helpers
    module NaturalLanguage

      def time_diff(from_time, to_time, opts={})
        opts = {}
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        intervals = %w(year month day hour minute second)
        values = intervals.map do |interval|
          distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
          delta = (distance_in_seconds / 1.send(interval)).floor
          delta -= 1 if from_time + delta.send(interval) > to_time
          from_time += delta.send(interval)
          delta
        end
        Hash[intervals.zip(values)]
      end
      
    end
  end
end

include Cinch::Helpers::NaturalLanguage
p time_diff(Time.now, Date.parse('2012-11-10'))