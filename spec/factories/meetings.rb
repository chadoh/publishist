Factory.define :meeting do |f|
  f.sequence(:when) {|n| Time.now + n.weeks}
  f.sequence(:question) {|n| "Tell me all your thoughts on '#{n}'"}
end
