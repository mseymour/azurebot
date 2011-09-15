class String
	def among?(*array)
    array.flatten.include?(self)
  end

	def among_case?(*array)
    array.flatten.map(&:downcase).include?(self.downcase);
	end

	def valid_nick?
		!!self.match(%r{^([^-\d][\w|{}\[\]\\^`-]+)$})
	end

	def irc_colorize
		self.gsub(/!\[(.*?)\]/) { $1.tr('boruic', 2.chr + 15.chr + 18.chr + 31.chr + 29.chr + 3.chr) }
		#Note to self, tr and gsub is your friend!
		#Thanks to j416 on #ruby@freenode!
	end

	def irc_colorize!
		replace irc_colorize
	end
	
	def irc_strip_colors
		self.gsub(/\x03([0-9]{2}(,[0-9]{2})?)?/,"")
	end

	def irc_strip_colors!
		replace irc_strip_colors
	end

end