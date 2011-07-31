class CreateStaffLists < ActiveRecord::Migration
  def self.up
    create_table :staff_lists do |t|
      t.belongs_to :page

      t.timestamps
    end

    add_foreign_key :staff_lists, :pages
  end

  def self.down
    drop_table :staff_lists
  end
end
