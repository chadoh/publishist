Delayed::Worker.delay_jobs = false

communicates = Ability.find_or_create_by_key_and_description 'communicates', "Can see the names of submitters and communicate with them."
scores =       Ability.find_or_create_by_key_and_description 'scores', "Can enter (and see) scores for all submissions."
orchestrates = Ability.find_or_create_by_key_and_description 'orchestrates', "Can organize meetings, record attendance, publish magazines, and specify staff."
views =        Ability.find_or_create_by_key_and_description 'views', "Can view meetings and attendees."
disappears =   Ability.find_or_create_by_key_and_description 'disappears', "Submitters & attendees are automatically added to this group. It will disappear once the magazine is published."

editor = Person.find_or_create_by_first_name_and_email('Simeon', 'editor@pc.com')
editor.update_attributes(
  :last_name => 'Pantalidis',
  :password => 'bubbles',
  :password_confirmation => 'bubbles',
)
editor.confirm!
coeditor = Person.find_or_create_by_first_name_and_email('Cheryl', 'coeditor@pc.com')
coeditor.update_attributes(
  :last_name => 'Fong',
  :password => 'bubbles',
  :password_confirmation => 'bubbles',
)
coeditor.confirm!
mckenzie = Person.find_or_create_by_first_name_and_email('McKenzie', 'pr@pc.com')
mckenzie.update_attributes(
  :last_name => 'Gupta',
  :password => 'bubbles',
  :password_confirmation => 'bubbles',
)
mckenzie.confirm!
swati = Person.find_or_create_by_first_name_and_email('Swati', 'swati@pc.com')
swati.update_attributes(
  :last_name => 'Prasad',
  :password => 'bubbles',
  :password_confirmation => 'bubbles',
)
swati.confirm!
mish = Person.find_or_create_by_first_name_and_email('Mish', 'mish@pc.com')
mish.update_attributes(
  :last_name => 'Irish',
  :password => 'bubbles',
  :password_confirmation => 'bubbles',
)
mish.confirm!

mag1 = Magazine.find_or_create_by_nickname('published')
mag1.update_attributes(
  :title => "Published",
  :accepts_submissions_from  => Time.zone.now - 13.months,
  :accepts_submissions_until => Time.zone.now - 7.months
)
mag2 = Magazine.find_or_create_by_nickname('almost published')
mag2.update_attributes(
  :title => "Almost Published",
  :accepts_submissions_from  => Time.zone.now - 7.months + 1.day,
  :accepts_submissions_until => Time.zone.now - 1.month
)
mag3 = Magazine.find_or_create_by_nickname('next')

saturnus = Submission.find_or_create_by_author_id_and_magazine_id(editor.id, mag3.id)
saturnus.update_attributes(
  :title => 'Saturnus Eateth Mortals Not',
  :body  => 'For gods was all she hadst been eating',
  :state => :submitted,
  :magazine_id => mag3
)
dooms = Submission.find_or_create_by_author_id_and_magazine_id(coeditor.id, mag3.id)
dooms.update_attributes(
  :title => 'my father moved through dooms of love',
  :body => "my father moved through dooms of love <br>through sames of am through haves of give, <br>singing each morning out of each night <br>my father moved through depths of height<br><br>this motionless forgetful where <br>turned at his glance to shining here; <br>that if(so timid air is firm) <br>under his eyes would stir and squirm",
  :state => :submitted,
  :magazine_id => mag3
)
water = Submission.find_or_create_by_author_id_and_magazine_id(mckenzie.id, mag3.id)
water.update_attributes(
  :title => "This is Water",
  :body => "Probably the most dangerous thing aboutan academic education, at least in my own case, is that it enables my tendency to over-intellectualize stuff, to get lost in abstract thinking instead of simply paying attention to what's going on in front of me.",
  :state => :submitted,
  :magazine_id => mag3
)
hold = Submission.find_or_create_by_author_id_and_magazine_id(swati.id, mag2.id)
hold.update_attributes(
  :title => "To Hold",
  :body => "One day we'll lie down and not get up again.<br>One day all we hold will be surrendered.",
  :state => :submitted,
  :magazine_id => mag2
)
howl = Submission.find_or_create_by_author_id_and_magazine_id(mish.id, mag1.id)
howl.update_attributes(
  :title => "Howl",
  :body => "I saw the best minds of my generation destroyed by madness, starving hysterical naked,<br>dragging themselves through the negro streets at dawn looking for an angry fix.",
  :state => :submitted,
  :magazine_id => mag1
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
Role.find_or_create_by_position_id_and_person_id(position1.id, mish.id)
Role.find_or_create_by_position_id_and_person_id(position2.id, swati.id)
Role.find_or_create_by_position_id_and_person_id(position3.id, mckenzie.id)
meeting = Meeting.find_or_create_by_magazine_id(mag1.id)
meeting.update_attributes(
  :datetime => Time.zone.now - 12.months,
  :question => "What is your spirit animal?"
)
packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, howl.id)
attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, mish.id)
attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, swati.id)
attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, mckenzie.id)
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
Role.find_or_create_by_position_id_and_person_id(position1.id, editor.id)
Role.find_or_create_by_position_id_and_person_id(position2.id, coeditor.id)
Role.find_or_create_by_position_id_and_person_id(position3.id, mckenzie.id)
meeting = Meeting.find_or_create_by_magazine_id(mag2.id)
meeting.update_attributes(
  :datetime => Time.zone.now - 6.months,
  :question => "Invent a new breakfast cereal."
)
packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, hold.id)
attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, editor.id)
attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, coeditor.id)
attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, mckenzie.id)
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
Role.find_or_create_by_position_id_and_person_id(position1.id, editor.id)
Role.find_or_create_by_position_id_and_person_id(position2.id, coeditor.id)
Role.find_or_create_by_position_id_and_person_id(position3.id, mckenzie.id)
meeting = Meeting.find_or_create_by_magazine_id(mag3.id)
meeting.update_attributes(
  :datetime => Time.zone.now - 1.week,
  :question => "What color is your underwear?"
)
packlet = Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, water.id)
attendee1 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, editor.id)
attendee2 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, coeditor.id)
attendee3 = Attendee.find_or_create_by_meeting_id_and_person_id(meeting.id, mckenzie.id)
attendee1.update_attributes(:answer => 'maroon & royal blue')
attendee2.update_attributes(:answer => 'tan')
attendee3.update_attributes(:answer => 'Underwear? What underwear?')
score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee1.id)
score.update_attributes(:amount => 3)
score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee2.id)
score.update_attributes(:amount => 6)
score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee3.id)
score.update_attributes(:amount => 5, :entered_by_coeditor => true)
