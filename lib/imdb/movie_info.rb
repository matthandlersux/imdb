module Imdb

  class MovieInfo

    attr_accessor :id, :title, :year, :thumbnail_url

    def initialize(id, title, year, thumbnail_url)
      @id = id
      @title = title
      @year = year
      @thumbnail_url = thumbnail_url
    end

  end

end