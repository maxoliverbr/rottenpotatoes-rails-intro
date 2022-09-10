class Movie < ActiveRecord::Base
  
  def self.ratings
    pluck(:rating).uniq
  end
  
  def self.find_all_by_ratings(ratings)
    where(rating: ratings)
  end
  
  def self.all_ratings
    ['G','PG','PG-13','R']
  end

  def self.with_ratings(rating)
    if rating.nil?
      return self.where(rating: self.all_ratings)
    else
      return self.where(rating: rating.keys.map!(&:upcase))
    end
  end
end
