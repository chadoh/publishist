# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :poetry_submission, :class => Composition do |f|
  f.title "This is poetry"
  f.body "Not art work. I'm not sure how to make that in a factory..."
  f.association :author, :factory => :person
end

#Factory.define :photo_submission, :class => Composition do |f|
  #f.attachment(:sample, "public/samples/sample.doc", "application/msword")
#end

Factory.define :anonymous_poetry_submission, :class => Composition do |f|
  f.title "This is poetry"
  f.body "Not art work. I'm not sure how to make that in a factory..."
  f.author_name "Mr. Wibbles"
  f.author_email "wibbles@whit.es"
end
