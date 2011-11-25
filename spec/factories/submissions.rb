Factory.define :submission do |s|
  s.sequence(:title) {|n| "Submission #{n}" }
  s.sequence(:body)  {|n| "#{n} awesome people lived in Carrboro" }
  s.association :author, :factory => :person
  s.state :submitted
end
