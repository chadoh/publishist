class CreatePseudonyms < ActiveRecord::Migration
  def up
    create_table :pseudonyms do |t|
      t.string :name
      t.boolean :link_to_profile, default: true
      t.belongs_to :submission

      t.timestamps
    end
    remove_column :submissions, :pseudonym
    add_foreign_key :pseudonyms, :submissions, dependent: :delete
  end

  def down
    drop_table :pseudonyms
    add_column :submissions, :pseudonym, :string
  end
end
