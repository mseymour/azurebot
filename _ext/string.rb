class String
	def among?(*array)
    array.flatten.include?(self)
  end

	def among_case?(*array)
    array.flatten.map(&:downcase).include?(self.downcase);
	end
end