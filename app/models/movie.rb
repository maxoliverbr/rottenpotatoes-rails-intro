class Movie < ActiveRecord::Base
  def self.all_ratings
    ['G','PG','PG-13','R']
  end

  def self.with_ratings(rating)
    self.where(rating: rating.keys)
  end
end
