Given(/^there is a issue$/) do
  Issue.create publication: Publication.first
end

Then(/^I should see a link to the issue$/) do
  find('a', text: Issue.first.to_s)
end

Given(/^a issue's timeframe is \*nearly\* over$/) do
  Issue.create(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.tomorrow,
    publication: Publication.first
  )
end

Given(/^a issue's timeframe is freshly over$/) do
  Issue.create(
    accepts_submissions_from: 6.months.ago,
    accepts_submissions_until: Date.yesterday,
    publication: Publication.first
  )
end

Given(/^a very old issue called "([^"]*)"$/) do |nickname|
  issue = Issue.create(
    accepts_submissions_from: 2.years.ago,
    accepts_submissions_until: 18.months.ago,
    nickname: nickname,
    publication: Publication.first
  ).publish []
end

Given(/^a current issue called "([^"]*)"$/) do |nickname|
  Issue.create(
    accepts_submissions_from: 3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    nickname: nickname,
    publication: Publication.first
  )
end


Given(/^the issue's timeframe is freshly over$/) do
  Issue.first.update_attributes(
    :accepts_submissions_from => 6.months.ago,
    :accepts_submissions_until => Date.yesterday
  )
end

Given(/^a issue has been published and I am viewing its cover$/) do
  date = Issue.first.accepts_submissions_from - 1.day
  issue = Issue.create(
    :title                     => 'banjos',
    :accepts_submissions_until => date,
    :accepts_submissions_from  => date - 6.months,
    publication: Publication.first
  )
  issue.publish []
  visit issue_path(issue)
end

Given(/^a issue (?:titled|nicknamed) "([^"]*)" has been published$/) do |title|
  issue = Issue.create(
    :nickname                  => title,
    :accepts_submissions_from  => 6.months.ago,
    :accepts_submissions_until => Date.yesterday,
    publication: Publication.first
  )
  Submission.find_each {|sub| sub.update_attributes issue: issue }
  issue.publish(Submission.all)
end

Given(/^(\d+) meetings? ha(?:ve|s) occured in it$/) do |num|
  issue = Issue.first
  num.to_i.times { issue.meetings << Factory.create(:meeting) }
end

Given(/^(\d+) submissions? ha(?:ve|s) been reviewed at th(?:ese|is) meetings?$/) do |total_submissions|
  issue = Issue.first
  total_meetings = issue.meetings.count
  for meeting in issue.meetings
    (total_submissions.to_i/total_meetings).times { meeting.submissions << Factory.create(:submission) }
  end
end

Given(/^1 person has attended each of these meetings$/) do
  # the viewer (the editor) already counts as 1
  @person ||= Factory.create :person
  for meeting in Issue.first.meetings
    Attendee.create :meeting => meeting, :person => @person
  end
end

Given(/^submissions at meeting 1 have all been scored 1, scored 2 at meeting 2, etc$/) do
  Issue.first.meetings.each_with_index do |meeting, i|
    for packlet in meeting.packlets
      for attendee in meeting.attendees
        Score.create :packlet => packlet, :attendee => attendee, :amount => i
      end
    end
  end
end

Given(/^10 submissions have been scored 1-10$/) do
  meeting = first_meeting
  issue = Issue.first
  10.times {|i|
    sub = Submission.create(
      title: "Submission #{i}",
      issue: issue,
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

Then(/^"([^"]*)" should be on page (\d) of (.*)$/) do |sub, page, issue|
  sub = Submission.find_by_title sub
  sub.page.to_s.should == page
  page = sub.page
  page.issue.should == Issue.find_by_nickname(issue)
end

Given(/^a issue that has been 'published' but has not yet had the notification sent out to everyone$/) do
  Issue.create(
    accepts_submissions_from: 6.months.ago,
    accepts_submissions_until: 2.days.ago,
    publication: Publication.first
  ).publish []
end

Given(/^that the issue has its notification sent out$/) do
  Issue.first.update_attributes notification_sent: true
end

When(/^I'm on page "(.*?)"$/) do |name|
  click_link name
end

When(/^I click on the page title \("(.*?)"\), type "(.*?)", and hit Return$/) do |old, new|
  page.first(:css, '.page', :text => old).click
  page.native.send_keys(new)
  page.sendEvent('keypress', 13)
end
