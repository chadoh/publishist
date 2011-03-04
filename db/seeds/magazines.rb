Magazine.create(
  :accepts_submissions_from  => Date.parse('20-Apr-2010'),
  :accepts_submissions_until => Date.parse('20-Nov-2010'),
  :nickname => 'Diner'
)
Magazine.create(
  :accepts_submissions_until => Date.parse('20-Apr-2011')
)
Meeting.all.each do |meeting|
  Magazine.all.each do |mag|
    meeting.update_attribute(:magazine_id, mag.id) if
      meeting.datetime > mag.accepts_submissions_from &&
      meeting.datetime < mag.accepts_submissions_until
  end
end
