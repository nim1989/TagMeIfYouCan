class Movie < ActiveRecord::Base
  validates :uri, :uniqueness => true
end
