module Imdb
  class Top250 < MovieList

    def movies
      @movies ||= parse_movie_infos
    end

    private

    LINK_MATCHER = ".titleColumn a[@href^='/title/tt']"

    def document
      @document ||= Nokogiri::HTML(open('http://akas.imdb.com/chart/top'))
    end

    def parse_movie_infos
      document.search(".lister-list tr").reject do |element|
        link = element.search(LINK_MATCHER).first
        should_reject_row?(link)
      end.map do |element|
        link = element.search(LINK_MATCHER).first
        id = link["href"][/\d+/]
        thumbnail_url = element.search(".posterColumn img").first["src"]
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
