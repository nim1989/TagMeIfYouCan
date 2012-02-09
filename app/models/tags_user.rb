class TagsUser < ActiveRecord::Base
  before_save :put_random_from_if_not
  belongs_to :user
  belongs_to :tag
  belongs_to :status
  belongs_to :from_user, :class_name => 'User'

  private
  def put_random_from_if_not
    if self.from_user_id.nil?
      self.from_user = User.first(:order => 'RAND()')
    end
  end
end
