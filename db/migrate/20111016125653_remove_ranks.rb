class RemoveRanks < ActiveRecord::Migration
  def up
    drop_table :ranks
  end

  def down
    create_table "ranks", :force => true do |t|
      t.integer  "person_id"
      t.integer  "rank_type"
      t.datetime "rank_start"
      t.datetime "rank_end"
      t.timestamps
    end
  end
end
