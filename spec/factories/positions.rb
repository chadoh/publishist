Factory.define :position do |f|
  f.sequence(:name) {|n| "Position #{n}" }
end
