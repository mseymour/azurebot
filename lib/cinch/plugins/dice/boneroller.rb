module Boneroller

  ATTACK_REGEXP = /^(?:(\d+)#)?(\d+)?d(\d+|%)(\S+)?/
  ELEMENTS_REGEXP = /([+-\/*])(?:(\d+)?d(\d+)|(\d+))|(-[HL])/

  class << self
    def is_valid?(s)
      !!s.match(ATTACK_REGEXP) 
    end
  end

  module Errors
    IncorrectFormatError = Class.new(StandardError)
    RollTooHighError = Class.new(RangeError)
    RollTooLowError = Class.new(RangeError)
  end

  # Represents a single turn.
  class Dice
    attr_reader :comment, :line, :rolls, :sum

    HIGH_ROLL_THRESHOLD = 100
    LOW_ROLL_THRESHOLD = 1

    def initialize(string)
      raise Errors::IncorrectFormatError, 'Your string does not appear to be a valid roll. Valid example: 1#2d3+4' if !string.match(ATTACK_REGEXP)
      @sum = 0
      @rolls = []
      @line, @comment = *string.split(" ",2)
      @comment = @line if @comment.to_s.strip.empty?
      @highest_roll_dropped, @lowest_roll_dropped = false, false
    end

    # DO A BARREL ROLL
    def roll
      repeat_by, dice, faces, elements = *@line.scan(ATTACK_REGEXP).flatten
      faces = 100 if faces.eql?('%') # Percentile dice
      repeat_by ||= 1 # Repeat our rolls
      dice ||= 1 # Dice count
      # Error out if we are rolling too much, or shooting the wind
      raise Errors::RollTooHighError if dice.to_i > HIGH_ROLL_THRESHOLD || repeat_by.to_i > HIGH_ROLL_THRESHOLD
      raise Errors::RollTooLowError if faces.to_i < LOW_ROLL_THRESHOLD || dice.to_i < LOW_ROLL_THRESHOLD || repeat_by.to_i < LOW_ROLL_THRESHOLD
      # Roll it!
      repeat_by.to_i.times {
        roll = attack_roll(dice, faces)
        @sum += attack_elements(roll, elements)
      }
    end
    alias_method :roll!, :roll

    def rolled?
      !@rolls.empty?
    end

    def to_s(include_rolls=false)
      rolls = @rolls.each_with_object([]) {|(notation,results),memo|
        memo << "[%s(%d)=%s]" % [notation, sum_ofArray(results), results * ","]
      }.join("; ")
      "#{@comment + ': ' if @comment}#@sum#{' (' + rolls + ')' if include_rolls}"
    end
    
    def inspect
      "#<Boneroller::Dice @comment=%s, @line=%s, @rolls=%s, @sum=%s>" % [@comment.inspect, @line.inspect, @rolls.inspect, @sum.inspect]
    end

    private

    def attack_roll(dice, faces)
      dice ||= 1
      $log.debug '#attack_roll(%p, %p)' % [dice.to_i, faces.to_i]
      # Rolls a die `dice` times, and returns the result of a random roll between 1 and the number of faces.
      results = Array.new(dice.to_i) { Random.rand(1..faces.to_i) }
      @rolls << ["#{dice}d#{faces}", results]
      results.inject(0, :+) # sum of results
    end

    def attack_elements(original_roll, elements)
      return original_roll unless elements
      parts = elements.scan(ELEMENTS_REGEXP)

      parts.inject(original_roll) {|roll_result, (operator, dice, faces, natural, lh)|
        if faces
          modifier = attack_roll(dice, faces)
        elsif natural
          modifier = natural.to_i
        else modifier = 0
        end

        case operator
        when "+" then roll_result += sum_ofArray(modifier)
        when "-" then roll_result -= sum_ofArray(modifier)
        when "/" then roll_result /= sum_ofArray(modifier)
        end

        case lh
        when "-L" then roll_result -= sum_ofArray(low_roll[1])
        when "-H" then roll_result -= sum_ofArray(high_roll[1])
        end

        roll_result
      }
    end

    def sum_ofArray(r)
      r.respond_to?(:reduce) ? r.reduce(0, :+) : r
    end

    def avg_ofArray(r)
      r.respond_to?(:reduce) ? r.reduce { |sum, el| sum + el }.to_f / r.size : r
    end

    def low_roll
      @rolls.to_a.sort {|(_,a),(_,b)| 
        avg_ofArray(a) <=> avg_ofArray(b) 
      }.first
    end

    def high_roll
      @rolls.to_a.sort {|(_,a),(_,b)| 
        avg_ofArray(a) <=> avg_ofArray(b) 
      }.last
    end
  end
end
