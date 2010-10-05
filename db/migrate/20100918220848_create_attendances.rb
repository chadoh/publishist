class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.belongs_to :meeting
      t.foreign_key :meeting, :dependent => :destroy
      t.belongs_to :person
      t.foreign_key :person
      t.string :answer

      t.timestamps
    end
  end

  def self.down
    drop_table :attendances
  end
end
