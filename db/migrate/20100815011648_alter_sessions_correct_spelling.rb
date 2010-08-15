class AlterSessionsCorrectSpelling < ActiveRecord::Migration
  def self.up
    rename_column :sessions, :ip_adddress, :ip_address
  end

  def self.down
    rename_column :sessions, :ip_address, :ip_adddress
  end
end
