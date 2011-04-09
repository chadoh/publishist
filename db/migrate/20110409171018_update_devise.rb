class UpdateDevise < ActiveRecord::Migration
  def self.up
    change_table(:people) do |t|
      t.remove :password_salt
      t.encryptable
    end
  end

  def self.down
  end
end
