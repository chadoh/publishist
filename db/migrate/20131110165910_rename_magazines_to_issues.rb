class RenameMagazinesToIssues < ActiveRecord::Migration
  def up
    remove_foreign_key :pages, :magazines
    remove_foreign_key :positions, :magazines
    remove_foreign_key :submissions, :magazines
    remove_foreign_key :magazines, :publications
    remove_index :magazines, name: "index_magazines_on_cached_slug"

    rename_table :magazines, :issues
    rename_column :meetings, :magazine_id, :issue_id
    rename_column :pages, :magazine_id, :issue_id
    rename_column :positions, :magazine_id, :issue_id
    rename_column :submissions, :magazine_id, :issue_id

    add_index :issues, :slug, unique: true
    add_foreign_key :issues, :publications
    add_foreign_key :meetings, :issues
    add_foreign_key :pages, :issues
    add_foreign_key :positions, :issues
    add_foreign_key :submissions, :issues
  end

  def down
    remove_index :issues, :slug
    remove_foreign_key :issues, :publications
    remove_foreign_key :meetings, :issues
    remove_foreign_key :pages, :issues
    remove_foreign_key :positions, :issues
    remove_foreign_key :submissions, :issues

    rename_table :issues, :magazines
    rename_column :meetings, :issue_id, :magazine_id
    rename_column :pages, :issue_id, :magazine_id
    rename_column :positions, :issue_id, :magazine_id
    rename_column :submissions, :issue_id, :magazine_id

    add_index :magazines, :slug, unique: true, name: "index_magazines_on_cached_slug"
    add_foreign_key :magazines, :publications
    add_foreign_key :pages, :magazines
    add_foreign_key :positions, :magazines
    add_foreign_key :submissions, :magazines
  end
end
