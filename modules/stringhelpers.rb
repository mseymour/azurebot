require 'active_support'
require 'active_support/core_ext'
require 'time'

module StringHelpers

  def time_diff_in_natural_language(from_time, to_time, acro = false)
    # TODO: cite the source of the method
    # TODO: Move this function to a separate file in ../_ext/ and have it a method of the Date class with an argument of "to_time".
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []

		%w(year month day hour minute second).map do |interval|
			distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
			delta = (distance_in_seconds / 1.send(interval)).floor
			delta -= 1 if from_time + delta.send(interval) > to_time
			from_time += delta.send(interval)
      if acro
        components << "#{delta}#{interval[0].downcase}" if delta > 0
      else
        components << "#{delta} #{delta > 1 ? interval.pluralize : interval}" if delta > 0
      end
    end
    if acro
      components.join(" ")
    else
      components.join(", ")
    end
  end

end