class AddBoardIdToStories < ActiveRecord::Migration
  def change
    add_column :stories, :board_id, :integer
  end
end
