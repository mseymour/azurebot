require_relative 'base'

module QDB
  class Bash < Base # Inheriting Base

    # attr_reader :name, :shortname, :url, :id_path_template, :random_path, :latest_path

    def initialize
      @name, @shortname, @url = "Bash.org", "bash", "http://bash.org/"
      @id_path_template = "?%<id>s"
      @random_path = "?random"
      @latest_path = "?latest"
    end

    def by_id(id)
      o = Nokogiri::HTML(open(@url + (@id_path_template % {id: id})))
      raise QDB::Error::QuoteNotFound.new(id), "Quote ##{id} does not exist." if o.at(".qt").nil?
      quotes = CGI.unescape_html o.at(".qt").children.to_s.gsub(/[\r\n]/,"")
      Quote.new(id, quotes.split(/<br *\/?>/i))
    end
    
    def random
      self.by_id(get_first_id(@url + @random_path))
    end

    def latest
      self.by_id(get_first_id(@url + @latest_path))
    end

    private

    def get_first_id(url)
      o = Nokogiri::HTML(open(url))
      o.at(".quote a b").children.to_s.strip.gsub("\r","").gsub("#","").to_i
    end

  end
end