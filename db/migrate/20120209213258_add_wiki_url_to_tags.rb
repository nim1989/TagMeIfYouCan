class AddWikiUrlToTags < ActiveRecord::Migration
  def change
    add_column :tags, :wikipedia_url, :string
  end
end
