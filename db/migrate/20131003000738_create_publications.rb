class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :domain, null: false
      t.string :name
      t.string :tagline
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_column(:magazines, :publication_id, :integer)
    add_column(:submissions, :publication_id, :integer)

    add_index(:publications, :domain, :unique => true)

    add_foreign_key(:magazines, :publications)
    add_foreign_key(:submissions, :publications)
  end
end
