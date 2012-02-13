class AddFromUserTagsUser < ActiveRecord::Migration
  def change
    add_column :tags_facebooks, :from_facebook_identifier, :integer
  end
end
