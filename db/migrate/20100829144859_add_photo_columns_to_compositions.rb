class AddPhotoColumnsToCompositions < ActiveRecord::Migration
  def self.up
    change_table :compositions do |t|
      t.string :photo_file_name, :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
    end
  end

  def self.down
    change_table :compositions do |t|
      t.remove :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at
    end
  end
end
