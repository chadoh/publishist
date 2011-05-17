class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.references :magazine
      t.integer :position
      t.string :title

      t.timestamps
    end
    add_foreign_key :pages, :magazines, :dependent => :delete
    add_column :submissions, :page_id, :integer
    add_foreign_key :submissions, :pages, :dependent => :nullify
  end

  def self.down
    remove_column :submissions, :page_id
    drop_table :pages
  end
end
