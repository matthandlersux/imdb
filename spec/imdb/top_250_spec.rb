require 'spec_helper'

describe Imdb::Top250 do
  before(:each) do
    @movies = Imdb::Top250.new.movies
  end

  it 'should be a list of movies' do
    @movies.each { |movie| movie.should be_an_instance_of(Imdb::MovieInfo) }
  end

  it 'should return the top 250 movies from IMDB.com' do
    @movies.size.should eq(250)
  end

  it 'should provide array like access to the movies' do
    @movies[0].title.should eq('The Shawshank Redemption')
    @movies[1].title.should eq('The Godfather')
    @movies[2].title.should eq('The Godfather: Part II')
  end
end
