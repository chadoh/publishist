class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :subdomain, null: false
      t.string :name
      t.string :tagline

      t.timestamps
    end
    create_table :publication_details do |t|
      t.belongs_to :publication
      t.text :about
      t.text :meetings_info
      t.string :address
      t.float :latitude
      t.float :longitude
    end
    add_column(:magazines, :publication_id, :integer)
    add_column(:submissions, :publication_id, :integer)

    add_index(:publications, :subdomain, :unique => true)

    add_foreign_key(:publication_details, :publications)
    add_foreign_key(:magazines, :publications)
    add_foreign_key(:submissions, :publications)
  end
end
