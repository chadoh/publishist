class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name, :middle_name, :last_name, :email, :salt, :encrypted_password

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
