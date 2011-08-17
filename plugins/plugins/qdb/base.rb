# -*- coding: utf-8 -*-

module QDB
	class QuoteDoesNotExistError < StandardError; end

	class Base
		attr_reader :fullname
		attr_accessor :id
		attr_reader :lines
		attr_reader :url
		
		@base_url = nil
		
		def initialize params={}
			id = params[:id]||nil;
			lines = params[:lines]||4;
			
			raise "@fullname must be set in #{self.class.name}#initialize." if @fullname.nil?
			raise "@base_url must be set in #{self.class.name}#initialize." if @base_url.nil?
			@base_url.freeze # This prevents the developer from screwing around with the variable.
			
			@id = (:"#{id}" == :latest || id.nil? ? self.retrieve_latest_quote_id : id)
			@lines = lines
			@url = "#{@base_url}?#{@id}"
		end
		
		def retrieve_latest_quote_id
			raise "retrieve_latest_quote_id must be overridden."
		end

		def retrieve_quote params={}
			raise "retrieve_quote must be overridden."
		end
	
		def retrieve_meta params={}
			raise "retrieve_meta must be overridden."
		end
		
		def to_hsh
			{
				fullname: @fullname,
				quote: self.retrieve_quote(:id => @id, :lines => @lines),
				fullquote: self.retrieve_quote(:id => @id),
				meta: self.retrieve_meta(:id => @id),
				id: @id,
				lines: @lines,
				url: @url
			}
		end
	
	end
end