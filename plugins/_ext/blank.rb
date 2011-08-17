class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class String
  # A string is blank if it's empty or contains whitespaces only:
  #
  #   "".blank?                 # => true
  #   "   ".blank?              # => true
  #   " something here ".blank? # => false
  #
  def blank?
    self !~ /\S/
  end
end