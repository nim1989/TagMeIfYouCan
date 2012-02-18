class AddUriColumnToFacebook < ActiveRecord::Migration
  def change
    add_column :facebooks, :uri, :string

  end
end
