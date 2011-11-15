class AddPseudonymToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :pseudonym, :string
  end
end
