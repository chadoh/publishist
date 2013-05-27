class UpdateSlugsToFriendlyIdSlugs < ActiveRecord::Migration
  def up
    rename_column :slugs, :name, :slug

    remove_column :slugs, :sequence
    remove_column :slugs, :scope

    change_column :slugs, :slug, :string, :null => false
    change_column :slugs, :sluggable_id, :integer, :null => false

    rename_table :slugs, :friendly_id_slugs

    add_index :friendly_id_slugs, [:slug, :sluggable_type], :unique => true
    add_index :friendly_id_slugs, :sluggable_type

    rename_column :people,      :cached_slug, :slug
    rename_column :magazines,   :cached_slug, :slug
    rename_column :submissions, :cached_slug, :slug
  end

  def down
    rename_column :people,      :slug, :cached_slug
    rename_column :magazines,   :slug, :cached_slug
    rename_column :submissions, :slug, :cached_slug

    remove_index :friendly_id_slugs, [:slug, :sluggable_type]
    remove_index :friendly_id_slugs, :sluggable_type

    rename_table :friendly_id_slugs, :slugs

    change_column :slugs, :slug, :string, :null => true
    change_column :slugs, :sluggable_id, :integer, :null => true

    add_column :slugs, :sequence, :integer, :null => false, :default => 1
    add_column :slugs, :scope, :string

    rename_column :slugs, :slug, :name
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  end
end
