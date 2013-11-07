class AddShowTipsAtPageLoadToPeople < ActiveRecord::Migration
  def change
    add_column :people, :show_tips_at_page_load, :boolean, default: true
  end
end
