class RenamePacketToPackletAndAttendanceToAttendee < ActiveRecord::Migration
  def self.up
    rename_table :packets, :packlets
    rename_table :attendances, :attendees
    change_table :scores do |t|
      t.rename :packet_id, :packlet_id
      t.rename :attendance_id, :attendee_id
    end
  end

  def self.down
    rename_table :packlets, :packets
    rename_table :attendees, :attendances
    change_table :scores do |t|
      t.rename :packlet_id, :packet_id
      t.rename :attendee_id, :attendance_id
    end
  end
end
