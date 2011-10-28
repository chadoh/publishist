class AddMagazineIdToSubmissions < ActiveRecord::Migration
  def up
    change_table :submissions do |t|
      t.belongs_to :magazine
    end
    add_foreign_key :submissions, :magazines
    Submission.all.each do |sub|
      sub.update_attribute :magazine, sub.meetings.first.try(:magazine)
    end
  end

  def down
    remove_column :submissions, :magazine_id
  end
end
