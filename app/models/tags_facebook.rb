class TagsFacebook < ActiveRecord::Base
  belongs_to :facebook     , :class_name => "Facebook", :foreign_key => "facebook_identifier", :primary_key => "identifier"
  belongs_to :from_facebook, :class_name => 'Facebook', :foreign_key => "from_facebook_identifier", :primary_key => "identifier"
  belongs_to :tag
  belongs_to :status

  validates :facebook_identifier     , :presence => true
  validates :from_facebook_identifier, :presence => true

end
