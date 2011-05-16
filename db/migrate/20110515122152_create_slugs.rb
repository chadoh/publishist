class CreateSlugs < ActiveRecord::Migration
  def self.up
    create_table :slugs do |t|
      t.string :name
      t.integer :sluggable_id
      t.integer :sequence, :null => false, :default => 1
      t.string :sluggable_type, :limit => 40
      t.string :scope
      t.datetime :created_at
    end
    add_index :slugs, :sluggable_id
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true

    add_column :magazines, :cached_slug, :string
    add_index  :magazines, :cached_slug, :unique => true

    add_column :people, :cached_slug, :string
    add_index  :people, :cached_slug, :unique => true

    add_column :submissions, :cached_slug, :string
    add_index  :submissions, :cached_slug, :unique => true
  end

  def self.down
    drop_table :slugs
    remove_column :magazines, :cached_slug
    remove_column :people, :cached_slug
    remove_column :submissions, :cached_slug
  end
end
