require_relative 'base'

module QDB
  class MIT < Base # Inheriting Base

    # attr_reader :name, :shortname, :url, :id_path_template, :random_path, :latest_path

    def initialize
      @name, @shortname, @url = "qdb.mit", "mit", "http://qdb.mit.edu/"
      @id_path_template = "%<id>d"
      @random_path = "rss/random"
      @latest_path = "rss/browse"
    end

    def by_id(id)
      o = Nokogiri::HTML(open(@url + (@id_path_template % {id: id})))
      raise QDB::Error::QuoteNotFound.new(id), "Quote ##{id} does not exist." if o.at(".quote-body").nil?
      quotes = CGI.unescape_html o.at(".quote-body").inner_text.gsub("\t","").strip
      Quote.new(id, quotes.split("\n"))
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
      o.xpath("//channel//item//title").to_a[0].text.scan(/\d+/).first
    end

  end
end