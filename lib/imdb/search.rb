module Imdb
  # Search IMDB for a title
  class Search < MovieList
    attr_reader :query

    LINK_MATCHER = ".result_text a[@href^='/title/tt']"

    # Initialize a new IMDB search with the specified query
    #
    #   search = Imdb::Search.new("Star Trek")
    #
    # Imdb::Search is lazy loading, meaning that unless you access the +movies+
    # attribute, no query is made to IMDB.com.
    #
    def initialize(query)
      @query = query
    end

    # Returns an array of Imdb::Movie objects for easy search result yielded.
    # If the +query+ was an exact match, a single element array will be returned.
    def movies
      @movies ||= parse_movie_infos
    end

    private

    def document
      @document ||= Nokogiri::HTML(Imdb::Search.query(@query))
    end

    def self.query(query)
      open("http://akas.imdb.com/find?q=#{CGI.escape(query)};s=tt&ttype=ft")
    end

    def parse_movie_infos
      document.search(".findResult").reject do |element|
        link = element.search(LINK_MATCHER).first
        should_reject_row?(link)
      end.map do |element|
        link = element.search(LINK_MATCHER).first
        id = link["href"][/\d+/]
        thumbnail_url = element.search(".primary_photo img").first["src"]
        title = sanitize_title(link)
        if matched = link.parent.text.match(/\((\d\d\d\d)\)/)
          year = matched[1]
        end

        if id and title
          Imdb::MovieInfo.new(id, title, year, thumbnail_url)
        end
      end.compact.uniq
    end

  end
end
