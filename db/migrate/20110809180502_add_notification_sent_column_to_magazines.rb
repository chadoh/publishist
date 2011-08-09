class AddNotificationSentColumnToMagazines < ActiveRecord::Migration
  def self.up
    add_column :magazines, :notification_sent, :boolean, default: false
  end

  def self.down
    remove_column :magazines, :notification_sent
  end
end
