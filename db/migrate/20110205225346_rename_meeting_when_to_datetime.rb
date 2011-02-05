class RenameMeetingWhenToDatetime < ActiveRecord::Migration
  def self.up
    rename_column :meetings, :when, :datetime
  end

  def self.down
    rename_column :meetings, :datetime, :when
  end
end
