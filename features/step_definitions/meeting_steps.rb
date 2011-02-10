Given /^there is a meeting scheduled$/ do
  Meeting.create :datetime => 7.days.from_now, :question => "orly?"
end
