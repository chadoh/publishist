def first_meeting
  Meeting.first || \
  Meeting.create(question: "Orly?", datetime: Time.now, magazine: Magazine.first || Magazine.create)
end
