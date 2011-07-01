	def strip_control_codes(w)
		w.gsub(/\x03[0-9]{2}(,[0-9]{2})?/,"") ;
	end
	
	# these are the supported colors

	WHITE = 0
	BLACK = 1
	BLUE  = 2
	NAVY  = 2
	GREEN = 3
	RED   = 4
	BROWN = 5
	MAROON = 5
	PURPLE = 6
	ORANGE = 7
	OLIVE = 7
	YELLOW = 8
	LT_GREEN = 9
	LIME = 9
	TEAL = 10
	LT_CYAN = 11
	AQUA = 11
	LT_BLUE = 12
	ROYAL = 12
	PINK = 13
	LT_PURPLE = 13
	FUCHSIA = 13
	GREY = 14
	LT_GREY = 15
	SILVER = 15

	# a reverse mapping, from color name to number

	COLORS = { 'white'    => WHITE,
	'black'    => BLACK,
	'blue'     => BLUE,
	'green'    => GREEN,
	'red'      => RED,
	'brown'    => BROWN,
	'purple'   => PURPLE,
	'orange'   => ORANGE,
	'yellow'   => YELLOW,
	'ltgreen'  => LT_GREEN,
	'teal'     => TEAL,
	'ltcyan'   => LT_CYAN,
	'ltblue'   => LT_BLUE,
	'pink'     => PINK,
	'grey'     => GREY,
	'ltgrey'   => LT_GREY }


	# formats the given text string.  Formatting codes are
	# prefixed with ![ and terminated with ].  Each ![...]
	# block may contain multiple formatting codes.  The supported
	# codes are:
	#
	#   b    : toggle bold
	#   u    : toggle underline
	#   o    : reset all attributes
	#   r    : toggle reverse text
	#   c    : reset text color back to the defaults
	#   i    : toggle italics
	#   |    : (pipe character) puts all preceding text in the gutter
	#   cn   : set the foreground color to #
	#   cn,n : set both the foreground and background colors
	#
	# 'n' (with the c code) may be either a number, or the name
	# of a color in parentheses.  For example:
	#
	#   ![c(red)b]This is bold,red![cb]

	def colorformat( text )
		text.gsub( /!\[(.*?)\]/ ) do |match|
		codes = $1.downcase
		repl = ""
		i = 0
		while i < codes.length
			case codes[i].chr
				when 'b'
					repl << 2.chr
				when 'o'
					repl << 15.chr
				when 'r'
					repl << 18.chr
				when 'u'
					repl << 31.chr
				when 'i'
					repl << 29.chr
				when '|'
					repl << 9.chr
				when 'c'
					bg = nil

					i, fg = extract_color( i+1, codes )
					i, bg = extract_color( i+1, codes ) if i < codes.length && codes[i].chr == ','

						repl << "" << ( fg || "" )
						repl << "," << bg if bg

						i -= 1
					end
					i += 1
			end #end case
		repl
		end #end while
	end #end def

	private

	def extract_color( i, s )
		return [ i, nil ] if i >= s.length

		if s[i].chr == '('
			j = s.index( ')', i )
			return [ j+1, "%02d" % COLORS[ s[i+1..j-1].downcase ] ]
		end

		j = i
		j += 1 while j < s.length && s[j].chr =~ /[0-9]/
		j += 1 if j == s.length
		return [ j, "%02d" % s[i..j-1].to_i ]
	end