Factory.define :meeting do |f|
  f.sequence(:datetime) {|n| Time.now + n.weeks}
  f.sequence(:question) {|n| "Tell me all your thoughts on '#{n}'"}
end
