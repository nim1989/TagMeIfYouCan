class AddFromUserTagsUser < ActiveRecord::Migration
  def change
    add_column :tags_facebooks, :from_facebook_id, :integer
  end
end
