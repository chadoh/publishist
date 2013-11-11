Factory.define :issue do |f|
  f.sequence(:title) {|n| "The Elegant Cat #{n}" }
  f.sequence(:nickname) {|n| "Cat #{n}" }
end
