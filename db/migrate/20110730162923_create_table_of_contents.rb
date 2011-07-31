class CreateTableOfContents < ActiveRecord::Migration
  def self.up
    create_table :table_of_contents do |t|
      t.belongs_to :page

      t.timestamps
    end

    add_foreign_key :table_of_contents, :pages
  end

  def self.down
    drop_table :table_of_contents
  end
end
