# -*- coding: utf-8 -*-
require 'active_support/core_ext/object/blank'

module Cinch
  module Helpers
    # Formats a supplied array into a list or table.
    # @author Mark Seymour ('Azure') (mark.seymour.ns@gmail.com)
    # 
    # @param [Array] array The source array.
    # @param [Hash] params Options for generating the table.
    # @option params [String] :splitchars ('\t') Characters to split each individual item on.
    # @option params [Regexp] :regexp (nil) A Regexp to split each individual item on. If one is supplied, then :splitchars is ignored.
    # @option params [Array] :justify ([:left]) Changes the justification of individual table items. If there are more headers set than column justifications, the default will be used. Valid options are :left or :right.
    # @option params [Array] :headers ([]) Sets the names for the table column headers. If left unset, no headers will be generated.
    # @option params [Integer] :gutter (4) Sets the gutter size between columns and optionally the left gutter.
    # @option params [Boolean] :left_gutter (false) Generates a gutter on the left side of the generated table, equal to the same length as column gutters.
    # @option params [Boolean] :display_indices (false) Shows the index #+1 of the row.
    # @option params [Boolean] :display_noitems (true) Displays a notice if there are no items to show.
    # @option params [String] :noitems_msg ("There is nothing to show.") Sets the message for display_noitems.
    # @option params [Boolean] :display_eot (true) Displays a notice at the end of the table.
    # @option params [String] :eot_msg ("End of results.") Sets the message for display_eot.
    # @todo Have the ability to output either an array or string (params[:array]?)
    # @return [String] The formatted string with line endings.
    def Helpers.table_format array, params={}
      params = {
        splitchars: "\t", 
        regexp: nil,
        justify: [:left], # :left, :right
        headers: [], # ary (ex: ["a","b","c"])
        gutter: 4,
        left_gutter: false,
        display_indices: false,
        display_noitems: true,
        noitems_msg: "There is nothing to show.",
        display_eot: true,
        eot_msg: "End of results."
      }.merge!(params)
      
      source = array.dup # We cannot be altering our original object now, can we?

      # We use the str.tr method if our regexp param is nil.
      # Otherwise, we just use regexp.
      # That is, unless we have a hash. Then we just make the columns be the keys and values.
      if source.is_a? Array
        source.map! {|e| 
          if e.is_a? String
            if params[:regexp].nil? 
              e.tr(params[:splitchars], "\t").split("\t") 
            else
              e.match(params[:regexp])[1..-1].map {|e| e.nil? ? "" : e; } 
            end
          elsif e.is_a? Array
            next
          else
            e.to_s
          end
        }
  #=begin
      elsif source.is_a? Hash
        source_new = []
        source.each {|key,value|
          source_new << [key.to_s, value.to_s]
        }
        source = source_new
  #=end
      end

      # calculating the maximum length of each column
      column_lengths = []
     
     # optional index
      if params[:display_indices]
        params[:justify].unshift(:right)
        params[:headers].unshift("#")
        source.each_with_index.map {|e,i| e.unshift(i.succ)}
      end

      source.dup.unshift(params[:headers]).each {|e| 
        e.each_with_index {|item,index| 
          column_lengths[index] = [] if column_lengths[index].blank?
          column_lengths[index] << item.size 
        }
      }
      column_lengths.map! {|e| e.sort.last }

      data = []

      # Generating table headers
      if !params[:headers].blank?
        # Generating the headers, separators, etc.
        s_header = []
        s_separator = s_header.dup
        params[:headers].each_with_index {|e,i|
          s_header << "%#{"-" if params[:justify][i] == :left || params[:justify][i].nil?}#{column_lengths[i]}s" % e.to_s
          s_separator << "-"*column_lengths[i]
        }
        data << s_header.join(" "*params[:gutter]) << s_separator.join(" "*params[:gutter])
      end

      # Generating formatted table rows
      if source.is_a? Array
        source.each {|e|
          line = []
          e.each_with_index {|item,index|
            line << "%#{"-" if params[:justify][index] == :left || params[:justify][index].nil?}#{column_lengths[index]}s" % item.to_s
          }
          data << line.join(" "*params[:gutter])
        }
      end

      # Adding noitems_msg if there are well... no items.
      if source.empty? && params[:display_noitems] then data << params[:noitems_msg] end
      
      # Adding EOT message
      if params[:display_eot]
        data << "-" * params[:eot_msg].length
        data << params[:eot_msg]
      end

      # Adding a gutter to the left side
      if params[:left_gutter] === true then data.map! {|e| " "*params[:gutter] + e } end
      
      data.join("\n")
    end
  end
end

__END__
my_array = ["column 1 r1 aa\tcolumn 2 r1 aaa\tcolumn 3 r1 aaaa",
            "column 1 r2 bbbb\tcolumn 2 r2 b\tcolumn 3 r2 bbbbbbbbb",
            "column 1 r3\tcolumn 2 r3 ffffffffff\tcolumn 3 r3 fff"]

puts Helpers.table_format my_array, justify: [:right,:left,:right], gutter: 2, headers: ["column 1","column 2","column3"], display_indices: true