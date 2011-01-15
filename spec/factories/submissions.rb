Factory.define :submission do |compo|
  compo.sequence(:title) {|n| "Submission #{n}" }
  compo.sequence(:body)  {|n| "#{n} awesome people lived in Carrboro" }
  compo.association :author, :factory => :person
end

Factory.define :anonymous_submission, :class => Submission do |compo|
  compo.sequence(:title) {|n| "Submission #{n}" }
  compo.sequence(:body)  {|n| "#{n} awesome people lived in Carrboro" }
  compo.sequence(:author_name) {|n| "Person #{n}" }
  compo.sequence(:author_email) {|n| "person#{n}@gmail.com" }
end