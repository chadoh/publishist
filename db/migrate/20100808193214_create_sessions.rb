class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.belongs_to :person
      t.foreign_key :person, :dependent => :destroy
      t.string :ip_adddress, :path

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
