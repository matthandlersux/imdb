# encoding: utf-8

require 'spec_helper'

# This test uses "Die hard (1988)" as a testing sample:
#
#     http://akas.imdb.com/title/tt0095016/combined
#

describe 'Imdb::Movie' do

  describe 'valid movie' do

    before(:each) do
      # Get Die Hard (1988)
      @movie = Imdb::Movie.new('0095016')
    end

    describe ".cast" do

      before(:each) do
        @cast = @movie.cast
      end

      it 'returns a list of people' do
        @cast.first.should be_an(Imdb::Person)
      end

      it 'finds cast members' do
        @cast.find{|p| p.name == 'Bruce Willis'}.should_not be_nil
        @cast.find{|p| p.name == 'Bonnie Bedelia'}.should_not be_nil
        @cast.find{|p| p.name == 'Alan Rickman'}.should_not be_nil
      end

    end

    it 'returns the url to the movie trailer' do
      @movie.trailer_url.should be_an(String)
      @movie.trailer_url.should == 'http://imdb.com/video/screenplay/vi581042457/'
    end

    it 'should find the director' do
      @movie.director.should be_an(Array)
      @movie.director.size.should eql(1)
      @movie.director.first.name.should =~ /John McTiernan/
    end

    it 'should find the company info' do
      @movie.company.should eql('Twentieth Century Fox Film Corporation')
    end

    it 'should find the genres' do
      genres = @movie.genres

      genres.should be_an(Array)
      genres.should include('Action')
      genres.should include('Thriller')
    end

    it 'should find the languages' do
      languages = @movie.languages

      languages.should be_an(Array)
      languages.size.should eql(3)
      languages.should include('English')
      languages.should include('German')
      languages.should include('Italian')
    end

    it 'should find the countries' do
      # The Dark Knight (2008)
      @movie = Imdb::Movie.new('0468569')
      countries = @movie.countries

      countries.should be_an(Array)
      countries.size.should eql(2)
      countries.should include('USA')
      countries.should include('UK')
    end

    it 'should find the length (in minutes)' do
      @movie.length.should eql(131)
    end

    it 'should find the plot' do
      @movie.plot.should eql('John McClane, officer of the NYPD, tries to save wife Holly Gennaro and several others, taken hostage by German terrorist Hans Gruber during a Christmas party at the Nakatomi Plaza in Los Angeles.')
    end

    it 'should find plot synopsis' do
      @movie.plot_synopsis.should include('John McClane, a detective with the New York City Police Department')
    end

    it 'should find plot summary' do
      @movie.plot_summary.should eql("New York City Detective John McClane has just arrived in Los Angeles to spend Christmas with his wife. Unfortunatly, it is not going to be a Merry Christmas for everyone. A group of terrorists, led by Hans Gruber is holding everyone in the Nakatomi Plaza building hostage. With no way of anyone getting in or out, it's up to McClane to stop them all. All 12!")
    end

    it 'should find the poster' do
      @movie.poster.should eql('http://ia.media-imdb.com/images/M/MV5BMTY4ODM0OTc2M15BMl5BanBnXkFtZTcwNzE0MTk3OA@@.jpg')
    end

    it 'should find the rating' do
      @movie.rating.should eql(8.3)
    end

    it 'should find number of votes' do
      @movie.votes.should be_within(10_000).of(475274)
    end

    it 'should find the title' do
      @movie.title.should =~ /Die Hard/
    end

    it 'should find the tagline' do
      @movie.tagline.should =~ /It will blow you through the back wall of the theater/
    end

    it 'should find the year' do
      @movie.year.should eql(1988)
    end

    describe 'special scenarios' do

      it 'should find multiple directors' do
        # The Matrix Revolutions (2003)
        movie = Imdb::Movie.new('0242653')

        movie.director.should be_an(Array)
        movie.director.size.should eql(2)
        movie.director.find{|d| d.name == 'Lana Wachowski' }.should_not be_nil
        movie.director.find{|d| d.name == 'Andy Wachowski' }.should_not be_nil
      end

      it 'should find writers' do
        # Waar (2013)
        movie  = Imdb::Movie.new('1821700')

        movie.writers.should be_an(Array)
        movie.writers.size.should eql(1)
        movie.writers.should include('Hassan Waqas Rana')
      end
    end

    it 'should find multiple filming locations' do
      filming_locations = @movie.filming_locations
      filming_locations.should be_an(Array)
      filming_locations.size.should eql(4)
      filming_locations[0].should match(/.*, USA$/i)
    end

    it "should find multiple 'also known as' versions" do
      also_known_as = @movie.also_known_as
      also_known_as.should be_an(Array)
      also_known_as.size.should be > 30
    end

    it "should find a specific 'also known as' version" do
      also_known_as = @movie.also_known_as
      also_known_as.should include(version: 'Russia', title: 'Крепкий орешек')
    end

    it 'should provide a convenience method to search' do
      movies = Imdb::Movie.search('Star Trek: TOS')
      movies.should respond_to(:each)
      movies.each { |movie| movie.should be_an_instance_of(Imdb::Movie) }
    end

    it 'should provide a convenience method to top 250' do
      movies = Imdb::Movie.top_250
      movies.should respond_to(:each)
      movies.each { |movie| movie.should be_an_instance_of(Imdb::Movie) }
    end
  end

  describe 'plot' do
    it 'should find a correct plot when HTML links are present' do
      movie = Imdb::Movie.new('0083987')
      movie.plot.should eql('Biography of Mohandas K. Gandhi, the lawyer who became the famed leader of the Indian revolts against the British rule through his philosophy of nonviolent protest.')
    end

    it "should not have a 'more' link in the plot" do
      movie = Imdb::Movie.new('0036855')
      movie.plot.should include('Years after her aunt was murdered in her home')
    end
  end

  describe 'mpaa rating' do
    it 'should find the mpaa rating when present' do
      movie = Imdb::Movie.new('0111161')
      movie.mpaa_rating.should == 'Rated R for language and prison violence (certificate 33087)'
    end

    it 'should be nil when not present' do
      movie = Imdb::Movie.new('0095016')
      movie.mpaa_rating.should be_nil
    end
  end

  describe 'with no submitted poster' do

    before(:each) do
      # Up Is Down (1969)
      @movie = Imdb::Movie.new('1401252')
    end

    it 'should have a title' do
      @movie.title(true).should =~ /Up Is Down/
    end

    it 'should have a year' do
      @movie.year.should eql(1969)
    end

    it 'should return nil as poster url' do
      @movie.poster.should be_nil
    end

    it 'should return the release date for movies' do
      movie = Imdb::Movie.new('0111161')
      movie.release_date.should eql('14 October 1994 (USA)')
    end
  end

  describe 'with an old poster (no @@)' do
    before(:each) do
      # Pulp Fiction (1994)
      @movie = Imdb::Movie.new('0110912')
    end

    it 'should have a poster' do
      @movie.poster.should eql('http://ia.media-imdb.com/images/M/MV5BMjE0ODk2NjczOV5BMl5BanBnXkFtZTYwNDQ0NDg4.jpg')
    end
  end

  describe 'with title that has utf-8 characters' do
    # WALL-E
    before(:each) do
      @movie = Imdb::Movie.search('Wall-E').first
    end

    it 'should give the proper title' do
      @movie.title.should == 'WALL·E (2008)'
    end
  end
end
