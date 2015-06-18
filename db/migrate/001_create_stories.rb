class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :url
      t.string :title
      
      t.timestamps
    end
  end
end
