Factory.define :publication do |f|
  f.sequence(:subdomain) {|n| "pub#{n}" }
  f.sequence(:custom_domain) {|n| "www.pub#{n}.dev" }
  f.sequence(:name) {|n| "Publication ##{n}" }
  f.tagline "A Pretty Awesome Literary Issue"
  f.association :publication_detail, strategy: :build
end
