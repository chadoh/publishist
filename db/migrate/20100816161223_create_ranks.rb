class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :ranks do |t|
      t.belongs_to :person
      t.foreign_key :person, :dependent => :destroy
      t.integer :rank_type
      t.datetime :rank_start
      t.datetime :rank_end

      t.timestamps
    end
  end

  def self.down
    drop_table :ranks
  end
end
