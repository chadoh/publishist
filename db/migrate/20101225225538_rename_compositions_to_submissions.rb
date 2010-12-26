class RenameCompositionsToSubmissions < ActiveRecord::Migration
  def self.up
    rename_table :compositions, :submissions
    change_table :packets do |t|
      t.rename :composition_id, :submission_id
      # Looks like my foreign keys might not be added at all... ?
      #t.remove_foreign_key :compositions
      #t.add_foreign_key :submissions
    end
  end

  def self.down
    rename_table :submissions, :compositions
    change_table :packets do |t|
      t.rename :submission_id, :composition_id
      #t.remove_foreign_key :submissions
      #t.add_foreign_key :compositions
    end
  end
end
