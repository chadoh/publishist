class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.belongs_to :magazine
      t.string :name

      t.timestamps
    end

    add_foreign_key :positions, :magazines
  end

  def self.down
    drop_table :positions
  end
end
