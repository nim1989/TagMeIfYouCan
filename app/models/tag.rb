class Tag < ActiveRecord::Base
  has_many :tags_users
  has_many :users, :through => :tags_users
  
  validates :uri, :presence => true

end
