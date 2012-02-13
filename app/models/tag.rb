class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks
  
  validates :uri, :presence => true

end
