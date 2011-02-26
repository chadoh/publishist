class AssociateMeetingsToMagazines < ActiveRecord::Migration
  def self.up
    change_table :meetings do |t|
      t.belongs_to :magazine
    end
    say_with_time "seeding magazines" do
      Rake::Task['db:seed:magazines'].invoke
    end
  end

  def self.down
    remove_column :meetings, :magazine_id
    Magazine.delete_all
  end
end
