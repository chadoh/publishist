class AddPositionToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :submissions, :position, :integer

    Page.all.each do |page|
      page.submissions.each_with_index do |sub, i|
        sub.update_attribute :position, i + 1
      end
    end
  end

  def self.down
    remove_column :submissions, :position
  end
end
