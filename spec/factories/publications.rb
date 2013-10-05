Factory.define :publication do |f|
  f.subdomain "problemchild"
  f.name "Problem Child"
  f.tagline "A Penn State Literary Magazine"
  f.association :publication_detail, strategy: :build
end
