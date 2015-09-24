class Movie < ActiveRecord::Base
  attr_accessible :title, :rating, :description, :release_date

  def self.select_byRating(rating_filter)
    movie_afterSort = self
    if rating_filter.nil? == false
      movie_afterSort = Movie.where({ rating: rating_filter })
    else movie_afterSort = {}
    end
    return movie_afterSort
  end
end
