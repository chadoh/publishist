def first_meeting
  Meeting.first || \
  Meeting.create(question: "Orly?", datetime: Time.now, issue: Issue.first || Issue.create)
end
