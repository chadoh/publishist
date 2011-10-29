Given /^there is a magazine$/ do
  Magazine.create
end

Then /^I should see a link to the magazine$/ do
  find('a', text: Magazine.first.to_s)
end

Given /^a magazine's timeframe is \*nearly\* over$/ do
  Magazine.create(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.tomorrow
  )
end

Given /^a magazine's timeframe is freshly over$/ do
  Magazine.create(
    accepts_submissions_from: 6.months.ago,
    accepts_submissions_until: Date.yesterday
  )
end

Given /^a very old magazine called "([^"]*)"$/ do |nickname|
  Magazine.create(
    accepts_submissions_from: 2.years.ago,
    accepts_submissions_until: 18.months.ago,
    nickname: nickname
  ).publish []
end

Given /^a current magazine called "([^"]*)"$/ do |nickname|
  Magazine.create(
    accepts_submissions_from: 3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    nickname: nickname
  )
end


Given /^the magazine's timeframe is freshly over$/ do
  Magazine.first.update_attributes(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.yesterday
  )
end

Given /^a magazine has been published and I am viewing its cover$/ do
  date = Magazine.first.accepts_submissions_from - 1.day
  mag = Magazine.create(
    :title                     => 'banjos',
    :accepts_submissions_until => date,
    :accepts_submissions_from  => date - 6.months
  )
  mag.publish []
  visit "/magazines/#{mag.to_param}"
end

Given /^a magazine titled "([^"]*)" has been published$/ do |title|
  mag = Magazine.create(
    :nickname                  => title,
    :accepts_submissions_from  => 6.months.ago,
    :accepts_submissions_until => Date.yesterday
  )
  meet = Meeting.create(
    :question => "orly?",
    :datetime => 3.weeks.ago
  )
  meet.submissions = Submission.all
  mag.publish(Submission.all)
end

Given /^10 meetings have occured in it$/ do
  mag = Magazine.first
  10.times { mag.meetings << Factory.create(:meeting) }
end

Given /^(\d+) submissions have been reviewed at these meetings$/ do |total_submissions|
  for meeting in Magazine.first.meetings
    (total_submissions.to_i/10).times { meeting.submissions << Factory.create(:submission) }
  end
end

Given /^1 person has attended each of these meetings$/ do
  # the viewer (the editor) already counts as 1
  for meeting in Magazine.first.meetings
    Attendee.create :meeting => meeting, :person => @user
  end
end

Given /^submissions at meeting 1 have all been scored 1, scored 2 at meeting 2, etc$/ do
  Magazine.first.meetings.each_with_index do |meeting, i|
    for packlet in meeting.packlets
      for attendee in meeting.attendees
        Score.create :packlet => packlet, :attendee => attendee, :amount => i
      end
    end
  end
end

Given /^10 submissions have been scored 1-10$/ do
  meeting = first_meeting
  10.times {
    meeting.submissions << Factory.create(:submission)
  }
  attendee = Attendee.create meeting: meeting, person: @user
  meeting.packlets.each_with_index do |packlet, i|
    Score.create packlet: packlet, attendee: attendee, amount: i
  end
end

Then /^I should see "([^"]*)" in the "([^"]*)" field$/ do |text, field|
  page.has_field? field, :with => text
end

Then /^I should see (\d+) submissions$/ do |how_many|
  on_page = page.find("body").text.split("Submission").length - 3
  on_page.should == how_many.to_i
end

Then /^each author should receive an email$/ do
  Submission.all.each do |sub|
    Then "\"#{sub.email}\" should receive an email"
  end
end
