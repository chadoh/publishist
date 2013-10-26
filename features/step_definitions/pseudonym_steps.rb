Given /^"([^"]*)" has a published poem called "([^"]*)" under an unlinked pseudonym$/ do |first_name, title|
  person = Person.create(
    first_name: first_name,
    email:      "#{first_name}@example.com",
    password:   'secret',
    password_confirmation: 'secret',
    primary_publication: Publication.first
  )
  mag = Magazine.create(
    accepts_submissions_from:  6.months.ago,
    accepts_submissions_until: 2.days.ago,
    published_on:              Date.yesterday,
    publication: Publication.first
  )
  poem = Submission.create(
    title: title,
    body:  "#{title}, y'all",
    magazine: mag,
    author: person,
    pseudonym_name: "wall-e",
    pseudonym_link: false
  )
end
