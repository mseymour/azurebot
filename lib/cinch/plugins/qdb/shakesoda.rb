require_relative 'base'

module QDB
  class Shakesoda < Base # Inheriting Base

    # attr_reader :name, :shortname, :url, :id_path_template, :random_path, :latest_path

    def initialize
      @name, @shortname, @url = "#shakesoda", "ss", "http://www.shakesoda.org/qdb/"
      @id_path_template = "view/%<id>s"
    end

    def by_id(id)
      o = Nokogiri::HTML(open(@url + (@id_path_template % {id: id})))
      raise QDB::Error::QuoteNotFound.new(id), "Quote ##{id} does not exist." if o.at(".quote").nil?
      quotes = CGI.unescape_html o.at(".quote-content").children.to_s.gsub("\r","")
      Quote.new(id, quotes.split(/<br *\/?>/i))
    end
    
    def random
      o = Nokogiri::HTML(open(@url))
      random = o.css(".quote .quote-header a[href*=\"qdb/view\"]").to_a.sample.inner_text.gsub("#",'')
      self.by_id(random)
    end

    def latest
      self.by_id(get_first_id(@url))
    end

    private

    def get_first_id(url)
      o = Nokogiri::HTML(open(@url))
      o.css(".quote .quote-header a[href*=\"qdb/view\"]").to_a.first.inner_text.gsub("#",'')
    end

  end
end