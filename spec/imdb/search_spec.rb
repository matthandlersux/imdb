require 'spec_helper'

describe 'Imdb::Search with multiple search results' do
  before(:each) do
    @search = Imdb::Search.new('Star Trek: TOS')
  end

  it 'should remember the query' do
    @search.query.should == 'Star Trek: TOS'
  end

  describe "movies" do

    it "returns movie info" do
      @search.movies.first.should be_an(Imdb::MovieInfo)
    end

    it "populates thumbnail for movie info" do
      @search.movies.first.thumbnail_url.should_not be_blank
    end

    it "populates year for movie info" do
      @search.movies.first.year.should match(/\d\d\d\d/)
    end

    it "populates movie id for movie info" do
      @search.movies.first.id.should match(/\d+/)
    end

    it 'should find results' do
      @search.movies.size.should be > 10
    end

    it 'should not return movies with no title' do
      @search.movies.each do |movie|
        movie.title.should_not be_blank
      end
    end

    it 'clips off the year' do
      @search.movies.first.title.should_not match(/\(\d\d\d\d\)/)
    end

    context "single result" do

      it 'should not raise an exception' do
        expect do
          @search = Imdb::Search.new('Kannethirey Thondrinal').movies
        end.not_to raise_error
      end

      it 'should return the movie id correctly' do
        @search = Imdb::Search.new('Kannethirey Thondrinal')
        @search.movies.first.id.should eql('0330508')
      end

    end

    describe "with filters" do

      context "movie only filter" do

      end

      context "tv only filter" do

      end

    end

  end

end
