Factory.define :submission do |s|
  s.sequence(:title) {|n| "Submission #{n}" }
  s.sequence(:body)  {|n| "#{n} awesome people lived in Carrboro" }
  s.association :author, :factory => :person
  s.state :submitted
end

Factory.define :anonymous_submission, :class => Submission do |s|
  s.sequence(:title) {|n| "Submission #{n}" }
  s.sequence(:body)  {|n| "#{n} awesome people lived in Carrboro" }
  s.sequence(:author_name) {|n| "Person #{n}" }
  s.sequence(:author_email) {|n| "person#{n}@gmail.com" }
end
