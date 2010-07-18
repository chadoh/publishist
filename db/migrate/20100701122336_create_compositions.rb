class CreateCompositions < ActiveRecord::Migration
  def self.up
    create_table :compositions do |t|
      t.text :title
      t.text :body
      t.string :author

      t.timestamps
    end
  end

  def self.down
    drop_table :compositions
  end
end
