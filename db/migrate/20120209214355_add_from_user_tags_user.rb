class AddFromUserTagsUser < ActiveRecord::Migration
  def change
    add_column :tags_users, :from_user_id, :integer
  end
end
