class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :amount
      t.references :attendance, :foreign_key => { :dependent => :nullify }
      t.references :packet, :foreign_key => { :dependent => :destroy }
      t.boolean :entered_by_coeditor, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
