pc = Publication.find_or_create_by_subdomain_and_name_and_tagline_and_custom_domain(
  'problemchild',
  'Problem Child',
  'A Penn State Literary Magazine',
  'www.problemchildmag.com'
)
details = pc.publication_detail || PublicationDetail.create(:publication => pc)
details.update_attributes(
  :address => "3rd Floor of The HUB, Pollack Rd, University Park, PA 16802",
  :latitude => 40.798231,
  :longitude => -77.860557,
  :about => "Problem Child offers an alternative medium for publication of poetry, prose, artwork, essays, and other creative media by semi-annually publishing the Problem Child Literary Magazine. Problem Child aims to publish and promote individual original thought by creating and hosting a creative community.",
  :meetings_info => "We meet every Monday at 7:30 by the fishtanks in the HUB. All are welcome to attend."
)
Magazine.  update_all(:publication_id => pc.id)
Submission.update_all(:publication_id => pc.id)
Person.    update_all(:primary_publication_id => pc.id)
