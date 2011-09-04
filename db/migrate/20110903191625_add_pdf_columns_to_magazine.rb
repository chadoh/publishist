class AddPdfColumnsToMagazine < ActiveRecord::Migration
  def self.up
    add_column :magazines, :pdf_file_name, :string
    add_column :magazines, :pdf_content_type, :string
    add_column :magazines, :pdf_file_size, :integer
    add_column :magazines, :pdf_updated_at, :datetime
  end

  def self.down
    remove_column :magazines, :pdf_updated_at
    remove_column :magazines, :pdf_file_size
    remove_column :magazines, :pdf_content_type
    remove_column :magazines, :pdf_file_name
  end
end
