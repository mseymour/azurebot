require 'httparty'
require 'nokogiri'

class Wikipedia
  include HTTParty
  base_uri 'en.wikipedia.org/w'
  headers 'User-Agent' => "HTTParty/#{HTTParty::VERSION} #{RUBY_ENGINE}/#{RUBY_VERSION}"

  Excerpt = Struct.new(:title, :summary, :type) do
    def title_to_url
      %q{http://en.wikipedia.org/w/index.php?title=%s} % [CGI.escape(self.title.gsub(/\s/, '_'))]
    end
  end

  def fetch(title)
    get_content(title)
  end

  def get_content(title, query={})
    query = { action: "query", prop: "extracts", format: "json", exlimit: "10", redirects: "", titles: title }.merge(query)
    response = self.class.get('/api.php', query: query)
    raise StandardError, response['error']['info'] if response.has_key?('error')
    article = response['query']['pages'].values[0]
    if article.has_key?('missing')
      new_title = get_search(title)[1][0]
      return get_content(new_title)
    end

    extract = Nokogiri::HTML article['extract']

    summary = []
    if is_disambiguation?(article['title'])
      summary << (extract.at('p').text.match(/refer to/i) ? extract.at('p').text : 'Did you mean:')
      articles = extract.css('body > ul li').to_a.map(&:text)
      summary << "#{articles.map(&:strip)[0..4].join(', ')}#{"... (and %d more)" % (articles.length - 5) if articles.length > 5}"
      Excerpt.new(article['title'], summary.flatten * $/, :disambiguation)
    else
      type = is_list?(article['title']) ? :list : :article
      length = extract.css('p')[0].text.size > 384 ? 0..0 : 0..1
      summary << extract.css('p')[length].map {|line| line.text.strip.chomp }
      Excerpt.new(article['title'], summary.flatten * $/, type)
    end
  end

  def is_list?(title, query={})
    get_categories(title).any? {|category| category =~ /\blists?\b/i }
  end

  def is_disambiguation?(title, query={})
    get_categories(title).any? {|category| category =~ /\bdisambiguation\b/i }
  end

  def get_categories(title, query={})
    query = { action: "query", prop: "categories", format: "json", cllimit: "20", redirects: "", titles: title }.merge(query)
  
    response = self.class.get('/api.php', query: query)
    raise StandardError, response['error']['info'] if response.has_key?('error')
    raise StandardError, 'txt' unless response['query']['pages'].values[0].has_key?('categories')
    response['query']['pages'].values[0]['categories'].map {|v| v['title'] }
  end

  def get_search(title, query={})
    query = { action: "opensearch", format: "json", search: title, limit: "10", namespace: "0", suggest: "" }.merge(query)
    response = self.class.get('/api.php', query: query)
    raise StandardError, 'No search results found.' if response[1].empty?
    return response
  end

end

__END__

w = Wikipedia.new

puts "MiWiki testbed 2 - #{RUBY_ENGINE}/#{RUBY_VERSION} #{RUBY_RELEASE_DATE}"
print "\nWikipage to fetch > "
input = gets.chomp

output = w.get_content(input)

puts output.title, output.summary, output.title_to_url

puts $\, "debug: This is a #{output.type} page."