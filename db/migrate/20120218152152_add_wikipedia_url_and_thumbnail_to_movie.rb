class AddWikipediaUrlAndThumbnailToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :wikipedia_url, :string

    add_column :movies, :thumbnail, :string

  end
end
