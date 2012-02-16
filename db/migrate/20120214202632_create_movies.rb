class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :uri
      t.string :label

      t.timestamps
    end
  end
end
