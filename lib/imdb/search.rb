module Imdb
  # Search IMDB for a title
  class Search < MovieList
    attr_reader :query

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

  end
end
