module Imdb
  class MovieList

    def movies
      @movies ||= parse_movies
    end

    private

    def parse_movies
      document.search("a[@href^='/title/tt']").reject do |element|
        should_reject_row?(element)
      end.map do |element|
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
      title.gsub!(/\s+/, ' ')
      title.gsub!(/^\s\d+\.\s/, '')

      if title =~ /\saka\s/
        titles = title.split(/\saka\s/)
        title = titles.shift.strip.imdb_unescape_html
      end

      title = title.strip
      title.blank? ? nil : title
    end

    def should_reject_row?(element)
      element.inner_html.imdb_strip_tags.empty? ||
        element.inner_html.imdb_strip_tags == 'X' ||
        element.parent.inner_html =~ /media from/i
    end

  end
end
