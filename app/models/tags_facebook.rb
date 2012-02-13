class TagsFacebook < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :tag
  belongs_to :status
  belongs_to :from_facebook, :class_name => 'Facebook'

  validates :facebook_id     , :presence => true
  validates :from_facebook_id, :presence => true

end
