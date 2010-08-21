class AddPersonIdAndAuthorEmailToCompositions < ActiveRecord::Migration
  def self.up
    change_table :compositions do |c|
      c.rename :author, :author_name
      c.belongs_to :author
      c.string :author_email
    end
    add_foreign_key(:compositions, :people, :column => 'author_id')
  end

  def self.down
    change_table :compositions do |c|
      c.remove :author_email
      c.remove_belongs_to :author
      c.rename :author_name, :author
    end
  end
end
