class AddFullNameToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :name, :first_name
      t.string :middle_name
      t.string :last_name
    end
  end

  def self.down
    change_table :users do |t|
      t.rename :first_name, :name
      t.remove :middle_name, :last_name
    end
  end
end
