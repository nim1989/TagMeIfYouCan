class AddIndexOnLabel < ActiveRecord::Migration
  def up
    add_index(:movies, :label)
  end

  def down
    remove_index(:movies, :column => :label)
  end
end
