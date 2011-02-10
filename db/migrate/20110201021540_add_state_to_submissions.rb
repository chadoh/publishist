class AddStateToSubmissions < ActiveRecord::Migration
  def self.up
    change_table 'submissions' do |t|
      t.column 'state', :integer, :limit => 7, :default => 0
    end
  end

  def self.down
    change_table 'submissions' do |t|
      t.remove 'state'
    end
  end
end
