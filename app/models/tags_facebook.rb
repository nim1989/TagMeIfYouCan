class TagsFacebook < ActiveRecord::Base
  belongs_to :facebook, :foreign_key => "facebook_identifier"
  belongs_to :tag
  belongs_to :status
  belongs_to :from_facebook, :class_name => 'Facebook', :foreign_key => "from_facebook_identifier"

  validates :facebook     , :presence => true
  validates :from_facebook, :presence => true

end
