class AddPersonNameToAttendances < ActiveRecord::Migration
  def self.up
    add_column :attendances, :person_name, :string
  end

  def self.down
    remove_column :attendances, :person_name
  end
end
