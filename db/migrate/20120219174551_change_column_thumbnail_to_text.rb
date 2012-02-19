class ChangeColumnThumbnailToText < ActiveRecord::Migration
  def up
    change_column :movies, :thumbnail, :text
    change_column :tags, :thumbnail, :text
  end

  def down
    change_column :movies, :thumbnail, :string
    change_column :tags, :thumbnail, :string
  end
end
