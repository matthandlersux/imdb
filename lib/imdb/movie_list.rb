module Imdb
  class MovieList

    LINK_MATCHER = ".result_text a[@href^='/title/tt']"

    def movies
      @movies ||= parse_movies
    end

    private

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

    def parse_movies
      document.search(LINK_MATCHER).reject(&:should_reject_row?).map do |element|
        id = element['href'][/\d+/]
        if title = sanitize_title(element)
          [id, title]
        else
          nil
        end
      end.compact.uniq.map do |values|
        Imdb::Movie.new(*values)
      end
    end

    def sanitize_title(element)
      data = element.parent.inner_html.split('<br />')
      title = (!data[0].nil? && !data[1].nil? && data[0] =~ /img/) ? data[1] : data[0]
      title = title.imdb_strip_tags.imdb_unescape_html
      title.gsub!(/\s+\(\d\d\d\d\)\s*$/, '')

      if title =~ /\saka\s/
        titles = title.split(/\saka\s/)
        title = titles.shift.strip.imdb_unescape_html
      end

      title.strip!.blank? ? nil : title
    end

    def should_reject_row?(element)
      element.inner_html.imdb_strip_tags.empty? ||
        element.inner_html.imdb_strip_tags == 'X' ||
        element.parent.inner_html =~ /media from/i
    end

  end
end
