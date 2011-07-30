class CreateEditorsNotes < ActiveRecord::Migration
  def self.up
    create_table :editors_notes do |t|
      t.belongs_to :page
      t.string :title
      t.text :body

      t.timestamps
    end

    add_foreign_key :editors_notes, :pages
  end

  def self.down
    drop_table :editors_notes
  end
end
