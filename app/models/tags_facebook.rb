class TagsFacebook < ActiveRecord::Base
  before_save :put_random_from_if_not

  belongs_to :facebook
  belongs_to :tag
  belongs_to :status
  belongs_to :from_facebook, :class_name => 'Facebook'

end
