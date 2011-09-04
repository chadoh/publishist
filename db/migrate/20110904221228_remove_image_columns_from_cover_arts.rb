class RemoveImageColumnsFromCoverArts < ActiveRecord::Migration
  def self.up
    remove_column :cover_arts, :image_updated_at
    remove_column :cover_arts, :image_file_size
    remove_column :cover_arts, :image_content_type
    remove_column :cover_arts, :image_file_name
  end

  def self.down
    add_column :cover_arts, :image_updated_at
    add_column :cover_arts, :image_file_size
    add_column :cover_arts, :image_content_type
    add_column :cover_arts, :image_file_name
  end
end
