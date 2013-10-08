Factory.define :publication do |f|
  f.sequence(:subdomain) {|n| "pub#{n}" }
  f.sequence(:name) {|n| "Publication ##{n}" }
  f.tagline "A Pretty Awesome Literary Magazine"
  f.association :publication_detail, strategy: :build
end
