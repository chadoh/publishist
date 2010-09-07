class AddVerifiedColumnToPeople < ActiveRecord::Migration
  class Person < ActiveRecord::Base
  end

  def self.up
    change_table :people do |t|
      t.boolean :verified, :default => false
    end
    Person.reset_column_information
    Person.update_all ["verified = ?", true]
  end

  def self.down
    change_table :people do |t|
      t.remove :verified
    end
  end
end
