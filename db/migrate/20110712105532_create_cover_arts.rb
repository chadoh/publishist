class CreateCoverArts < ActiveRecord::Migration
  def self.up
    create_table :cover_arts do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.belongs_to :page

      t.timestamps
    end

    add_foreign_key :cover_arts, :pages
  end

  def self.down
    drop_table :cover_arts
  end
end
