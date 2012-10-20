require 'active_support/time'
require 'active_support/core_ext/array/conversions'

module Cinch
  module Helpers
    module NaturalLanguage

      def time_distance(from_time, to_time, opts={})
        opts = {show_seconds: false}.merge(opts)
        if from_time > to_time # swap if reversed
          from_time, to_time = to_time, from_time
          reversed = true
        end
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
        mapping = intervals.zip(values).reject {|(l,i)| !opts[:show_seconds] && l.eql?('second') || i < 1 }
        mapping.map! {|(l,i)| '%d %s' % [i, i != 1 ? l.pluralize : l] }
        reversed ? mapping.to_sentence + ' ago' : mapping.to_sentence
      end
      
    end
  end
end
