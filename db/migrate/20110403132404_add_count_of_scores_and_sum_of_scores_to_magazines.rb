class AddCountOfScoresAndSumOfScoresToMagazines < ActiveRecord::Migration
  def self.up
    change_table :magazines do |t|
      t.integer :count_of_scores, :default => 0
      t.integer :sum_of_scores, :default => 0
    end
    Magazine.all.each do |m|
      packlet_ids = m.meetings.collect(&:packlets).flatten.collect &:id
      count = Score.where(:packlet_id + packlet_ids).length
      sum = Score.sum('amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})") unless packlet_ids.blank?
      m.update_attributes(
        :count_of_scores => count,
        :sum_of_scores => sum
      )
    end
  end

  def self.down
    change_table :magazines do |t|
      t.remove :count_of_scores
      t.remove :sum_of_scores
    end
  end
end
