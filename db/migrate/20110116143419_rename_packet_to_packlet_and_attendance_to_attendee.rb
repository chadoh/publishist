class RenamePacketToPackletAndAttendanceToAttendee < ActiveRecord::Migration
  def self.up
    rename_table :packets, :packlets
    rename_table :attendances, :attendees
  end

  def self.down
    rename_table :packlets, :packet
    rename_table :attendees, :attendances
  end
end
