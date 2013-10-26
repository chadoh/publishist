Given(/^there is a magazine$/) do
  Magazine.create publication: Publication.first
end

Then(/^I should see a link to the magazine$/) do
  find('a', text: Magazine.first.to_s)
end

Given(/^a magazine's timeframe is \*nearly\* over$/) do
  Magazine.create(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.tomorrow,
    publication: Publication.first
  )
end

Given(/^a magazine's timeframe is freshly over$/) do
  Magazine.create(
    accepts_submissions_from: 6.months.ago,
    accepts_submissions_until: Date.yesterday,
    publication: Publication.first
  )
end

Given(/^a very old magazine called "([^"]*)"$/) do |nickname|
  mag = Magazine.create(
    accepts_submissions_from: 2.years.ago,
    accepts_submissions_until: 18.months.ago,
    nickname: nickname,
    publication: Publication.first
  ).publish []
end

Given(/^a current magazine called "([^"]*)"$/) do |nickname|
  Magazine.create(
    accepts_submissions_from: 3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    nickname: nickname,
    publication: Publication.first
  )
end


Given(/^the magazine's timeframe is freshly over$/) do
  Magazine.first.update_attributes(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.yesterday
  )
end

Given(/^a magazine has been published and I am viewing its cover$/) do
  date = Magazine.first.accepts_submissions_from - 1.day
  mag = Magazine.create(
    :title                     => 'banjos',
    :accepts_submissions_until => date,
    :accepts_submissions_from  => date - 6.months,
    publication: Publication.first
  )
  mag.publish []
  visit magazine_path(mag)
end

Given(/^a magazine (?:titled|nicknamed) "([^"]*)" has been published$/) do |title|
  mag = Magazine.create(
    :nickname                  => title,
    :accepts_submissions_from  => 6.months.ago,
    :accepts_submissions_until => Date.yesterday,
    publication: Publication.first
  )
  Submission.find_each {|sub| sub.update_attributes magazine: mag }
  mag.publish(Submission.all)
end

Given(/^(\d+) meetings? ha(?:ve|s) occured in it$/) do |num|
  mag = Magazine.first
  num.to_i.times { mag.meetings << Factory.create(:meeting) }
end

Given(/^(\d+) submissions? ha(?:ve|s) been reviewed at th(?:ese|is) meetings?$/) do |total_submissions|
  mag = Magazine.first
  total_meetings = mag.meetings.count
  for meeting in mag.meetings
    (total_submissions.to_i/total_meetings).times { meeting.submissions << Factory.create(:submission) }
  end
end

Given(/^1 person has attended each of these meetings$/) do
  # the viewer (the editor) already counts as 1
  @person ||= Factory.create :person
  for meeting in Magazine.first.meetings
    Attendee.create :meeting => meeting, :person => @person
  end
end

Given(/^submissions at meeting 1 have all been scored 1, scored 2 at meeting 2, etc$/) do
  Magazine.first.meetings.each_with_index do |meeting, i|
    for packlet in meeting.packlets
      for attendee in meeting.attendees
        Score.create :packlet => packlet, :attendee => attendee, :amount => i
      end
    end
  end
end

Given(/^10 submissions have been scored 1-10$/) do
  meeting = first_meeting
  magazine = Magazine.first
  10.times {|i|
    sub = Submission.create(
      title: "Submission #{i}",
      magazine: magazine,
      state: :submitted,
      author: @person
    )
    meeting.submissions << sub
  }
  @person ||= Factory.create :person
  attendee = Attendee.create meeting: meeting, person: @person
  meeting.packlets.each_with_index do |packlet, i|
    packlet.scores.create attendee: attendee, amount: i
  end
end

Then(/^I should see "([^"]*)" in the "([^"]*)" field$/) do |text, field|
  page.has_field? field, :with => text
end

Then(/^I should see (\d+) submissions$/) do |how_many|
  on_page = page.find("body").text.split("Submission").length - 3
  on_page.should == how_many.to_i
end

Then(/^each author should receive an email$/) do
  Submission.all.each do |sub|
    unread_emails_for(sub.email).size.should == 1
  end
end

Then(/^"([^"]*)" should be on page (\d) of (.*)$/) do |sub, page, mag|
  sub = Submission.find_by_title sub
  sub.page.to_s.should == page
  page = sub.page
  page.magazine.should == Magazine.find_by_nickname(mag)
end

Given(/^a magazine that has been 'published' but has not yet had the notification sent out to everyone$/) do
  Magazine.create(
    accepts_submissions_from: 6.months.ago,
    accepts_submissions_until: 2.days.ago,
    publication: Publication.first
  ).publish []
end

Given(/^that the magazine has its notification sent out$/) do
  Magazine.first.update_attributes notification_sent: true
end

When(/^I'm on page "(.*?)"$/) do |name|
  click_link name
end

When(/^I click on the page title \("(.*?)"\), type "(.*?)", and hit Return$/) do |old, new|
  page.first(:css, '.page', :text => old).click
  page.native.send_keys(new)
  page.sendEvent('keypress', 13)
end
