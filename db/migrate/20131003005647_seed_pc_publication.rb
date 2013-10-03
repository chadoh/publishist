class SeedPcPublication < ActiveRecord::Migration
  def up
    pc = Publication.create(
      :domain => 'problemchild',
      :name => 'Problem Child',
      :tagline => 'A Penn State Literary Magazine',
      :address => "3rd Floor of The HUB, Pollack Rd, University Park, PA 16802",
      :latitude => 40.798231,
      :longitude => -77.860557
    )
    Magazine.  update_all(:publication_id => pc.id)
    Submission.update_all(:publication_id => pc.id)
  end
end
