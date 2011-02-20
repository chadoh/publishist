class CreateMagazines < ActiveRecord::Migration
  def self.up
    create_table :magazines do |t|
      t.string :title
      t.string :nickname
      t.datetime :accepts_submissions_from
      t.datetime :accepts_submissions_until
      t.datetime :published_on

      t.timestamps
    end
  end

  def self.down
    drop_table :magazines
  end
end
