class CreateTagsFacebooks < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :name, :unique => true
    end

    Status.create(:name => 'pending')
    
    create_table :tags_facebooks do |t|
      t.string  :facebook_identifier
      t.integer :tag_id
      t.integer :status_id, :default => Status.where(:name => 'pending').first.id
      t.timestamps
    end
  end
end
