Delayed::Worker.delay_jobs = false

communicates = Ability.find_or_create_by_key_and_description 'communicates', "Can see the names of submitters and communicate with them."
scores =       Ability.find_or_create_by_key_and_description 'scores', "Can enter (and see) scores for all submissions."
orchestrates = Ability.find_or_create_by_key_and_description 'orchestrates', "Can organize meetings, record attendance, publish magazines, and specify staff."
views =        Ability.find_or_create_by_key_and_description 'views', "Can view meetings and attendees."
disappears =   Ability.find_or_create_by_key_and_description 'disappears', "Submitters & attendees are automatically added to this group. It will disappear once the magazine is published."

[
  Publication.find_or_create_by_subdomain_and_name_and_tagline('problemchild', 'Problem Child', 'A Penn State Literary Magazine'),
  Publication.find_or_create_by_subdomain_and_name_and_tagline('conspire', 'Conspire', 'Scheme Goodness Together'),
].each do |publication|
  publication.publication_detail ||= PublicationDetail.create(:about => "We #{publication.name}, and that's all there really is to it! We'd like you to join us.")

  person1 = Person.find_or_create_by_first_name_and_email_and_primary_publication_id('Simeon', "editor@#{publication.subdomain}.com", publication.id)
  person1.update_attributes(
    :last_name => 'Pantalidis',
    :password => 'bubbles',
    :password_confirmation => 'bubbles',
  )
  person1.confirm!
  person2 = Person.find_or_create_by_first_name_and_email_and_primary_publication_id('Cheryl', "coeditor@#{publication.subdomain}.com", publication.id)
  person2.update_attributes(
    :last_name => 'Fong',
    :password => 'bubbles',
    :password_confirmation => 'bubbles',
  )
  person2.confirm!
  person3 = Person.find_or_create_by_first_name_and_email_and_primary_publication_id('McKenzie', "mckenzie@#{publication.subdomain}.com", publication.id)
  person3.update_attributes(
    :last_name => 'Gupta',
    :password => 'bubbles',
    :password_confirmation => 'bubbles',
  )
  person3.confirm!
  person4 = Person.find_or_create_by_first_name_and_email_and_primary_publication_id('Swati', "swati@#{publication.subdomain}.com", publication.id)
  person4.update_attributes(
    :last_name => 'Prasad',
    :password => 'bubbles',
    :password_confirmation => 'bubbles',
  )
  person4.confirm!
  person5 = Person.find_or_create_by_first_name_and_email_and_primary_publication_id('Janell', "janell@#{publication.subdomain}.com", publication.id)
  person5.update_attributes(
    :last_name => 'Anema',
    :password => 'bubbles',
    :password_confirmation => 'bubbles',
  )
  person5.confirm!

  mag1 = Magazine.find_or_create_by_nickname_and_title_and_publication_id('published', "#{publication.name} vol. 1", publication.id)
  mag1.update_attributes(
    :accepts_submissions_from  => Time.zone.now - 13.months,
    :accepts_submissions_until => Time.zone.now - 7.months,
    :publication_id => publication.id
  )
  mag2 = Magazine.find_or_create_by_nickname_and_title_and_publication_id('almost published', "#{publication.name} vol. 2", publication.id)
  mag2.update_attributes(
    :accepts_submissions_from  => Time.zone.now - 7.months + 1.day,
    :accepts_submissions_until => Time.zone.now - 1.month,
    :publication_id => publication.id
  )
  mag3 = Magazine.find_or_create_by_nickname_and_title_and_publication_id('next', "#{publication.name} vol. 3", publication.id)
  mag3.update_attributes(
    :publication_id => publication.id
  )

  saturnus = Submission.find_or_create_by_author_id_and_magazine_id(person1.id, mag3.id)
  saturnus.update_attributes(
    :title => 'Saturnus Eateth Mortals Not',
    :body  => 'For gods was all she hadst been eating',
    :state => :submitted,
    :magazine_id => mag3,
    :publication_id => publication.id
  )
  dooms = Submission.find_or_create_by_author_id_and_magazine_id(person2.id, mag3.id)
  dooms.update_attributes(
    :title => 'my father moved through dooms of love',
    :body => "my father moved through dooms of love <br>through sames of am through haves of give, <br>singing each morning out of each night <br>my father moved through depths of height<br><br>this motionless forgetful where <br>turned at his glance to shining here; <br>that if(so timid air is firm) <br>under his eyes would stir and squirm",
    :state => :submitted,
    :magazine_id => mag3,
    :publication_id => publication.id
  )
  water = Submission.find_or_create_by_author_id_and_magazine_id(person3.id, mag3.id)
  water.update_attributes(
    :title => "This is Water",
    :body => "Probably the most dangerous thing about an academic education, at least in my own case, is that it enables my tendency to over-intellectualize stuff, to get lost in abstract thinking instead of simply paying attention to what's going on in front of me.",
    :state => :submitted,
    :magazine_id => mag3,
    :publication_id => publication.id
  )
  hold = Submission.find_or_create_by_author_id_and_magazine_id(person4.id, mag2.id)
  hold.update_attributes(
    :title => "To Hold",
    :body => "One day we'll lie down and not get up again.<br>One day all we hold will be surrendered.",
    :state => :submitted,
    :magazine_id => mag2,
    :publication_id => publication.id
  )
  howl = Submission.find_or_create_by_author_id_and_magazine_id(person5.id, mag1.id)
  howl.update_attributes(
    :title => "Howl",
    :body => "I saw the best minds of my generation destroyed by madness, starving hysterical naked,<br>dragging themselves through the negro streets at dawn looking for an angry fix.",
    :state => :submitted,
    :magazine_id => mag1,
    :publication_id => publication.id
  )

  ###############
  ### ISSUE 1 ###
  ###############
  position1 = Position.find_or_create_by_magazine_id_and_name(mag1.id, "Editor")
  position2 = Position.find_or_create_by_magazine_id_and_name(mag1.id, "Coeditor")
  position3 = Position.find_or_create_by_magazine_id_and_name(mag1.id, "Staff")
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, communicates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id,       scores.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position3.id,        views.id)
  Role.find_or_create_by_position_id_and_person_id(position1.id, person5.id)
  Role.find_or_create_by_position_id_and_person_id(position2.id, person4.id)
  Role.find_or_create_by_position_id_and_person_id(position3.id, person3.id)
  meeting = Meeting.find_or_create_by_magazine_id(mag1.id)
  meeting.update_attributes(
    :datetime => Time.zone.now - 12.months,
    :question => "What is your spirit animal?"
  )
  packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, howl.id)
  attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person5.id)
  attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person4.id)
  attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person3.id)
  attendee1.update_attributes(:answer => 'unicorn')
  attendee2.update_attributes(:answer => 'marmot')
  attendee3.update_attributes(:answer => 'bulldozer')
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee1.id)
  score.update_attributes(:amount => 10, :entered_by_coeditor => true)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee2.id)
  score.update_attributes(:amount => 2, :entered_by_coeditor => true)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee3.id)
  score.update_attributes(:amount => 5, :entered_by_coeditor => true)
  mag1.publish([howl])
  mag1.notify_authors_of_published_magazine

  ###############
  ### ISSUE 2 ###
  ###############
  position1 = Position.find_or_create_by_magazine_id_and_name(mag2.id, "Editor")
  position2 = Position.find_or_create_by_magazine_id_and_name(mag2.id, "Coeditor")
  position3 = Position.find_or_create_by_magazine_id_and_name(mag2.id, "Staff")
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, communicates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id,       scores.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position3.id,        views.id)
  Role.find_or_create_by_position_id_and_person_id(position1.id, person1.id)
  Role.find_or_create_by_position_id_and_person_id(position2.id, person2.id)
  Role.find_or_create_by_position_id_and_person_id(position3.id, person3.id)
  meeting = Meeting.find_or_create_by_magazine_id(mag2.id)
  meeting.update_attributes(
    :datetime => Time.zone.now - 6.months,
    :question => "Invent a new breakfast cereal."
  )
  packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, hold.id)
  attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person1.id)
  attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person2.id)
  attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person3.id)
  attendee1.update_attributes(:answer => 'butternut squashies')
  attendee2.update_attributes(:answer => 'marmot marmalade')
  attendee3.update_attributes(:answer => 'klingon corn')
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee1.id)
  score.update_attributes(:amount => 8)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee2.id)
  score.update_attributes(:amount => 5)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee3.id)
  score.update_attributes(:amount => 5, :entered_by_coeditor => true)
  mag2.publish([hold])

  ###############
  ### ISSUE 3 ###
  ###############
  position1 = Position.find_or_create_by_magazine_id_and_name(mag3.id, "Editor")
  position2 = Position.find_or_create_by_magazine_id_and_name(mag3.id, "Coeditor")
  position3 = Position.find_or_create_by_magazine_id_and_name(mag3.id, "Staff")
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, communicates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position1.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id,       scores.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position2.id, orchestrates.id)
  PositionAbility.find_or_create_by_position_id_and_ability_id(position3.id,        views.id)
  Role.find_or_create_by_position_id_and_person_id(position1.id, person1.id)
  Role.find_or_create_by_position_id_and_person_id(position2.id, person2.id)
  Role.find_or_create_by_position_id_and_person_id(position3.id, person3.id)
  meeting = Meeting.find_or_create_by_magazine_id(mag3.id)
  meeting.update_attributes(
    :datetime => Time.zone.now - 1.week,
    :question => "What color is your underwear?"
  )
  packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, water.id)
  attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person1.id)
  attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person2.id)
  attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, person3.id)
  attendee1.update_attributes(:answer => 'maroon & royal blue')
  attendee2.update_attributes(:answer => 'tan')
  attendee3.update_attributes(:answer => 'Underwear? What underwear?')
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee1.id)
  score.update_attributes(:amount => 3)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee2.id)
  score.update_attributes(:amount => 6)
  score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee3.id)
  score.update_attributes(:amount => 5, :entered_by_coeditor => true)
end
