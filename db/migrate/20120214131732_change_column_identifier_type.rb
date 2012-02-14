class ChangeColumnIdentifierType < ActiveRecord::Migration
  def up
    change_column :tags_facebooks, :facebook_identifier, :string
    change_column :tags_facebooks, :from_facebook_identifier, :string
  end

  def down
    change_column :tags_facebooks, :facebook_identifier, :integer
    change_column :tags_facebooks, :from_facebook_identifier, :integer
  end
end
