class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.belongs_to :person
      t.belongs_to :position

      t.timestamps
    end

    add_foreign_key :roles, :people
    add_foreign_key :roles, :positions
  end

  def self.down
    drop_table :roles
  end
end
