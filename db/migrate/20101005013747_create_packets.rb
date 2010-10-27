class CreatePackets < ActiveRecord::Migration
  def self.up
    create_table :packets do |t|
      t.integer :meeting_id
      t.integer :composition_id
      t.integer :position
      t.foreign_key :meetings, :dependent => :destroy
      t.foreign_key :compositions, :dependent => :destroy

      t.timestamps
    end
  end

  def self.down
    drop_table :packets
  end
end
