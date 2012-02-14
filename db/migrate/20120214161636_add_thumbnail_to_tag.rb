class AddThumbnailToTag < ActiveRecord::Migration
  def change
    add_column :tags, :thumbnail, :string
  end
end
