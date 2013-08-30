class Entry
  attr_accessor :author_name, :author_email, :title, :body, :semester
  def initialize(author_name, author_email, title, body, semester, date_of_submission)
    @author_name = author_name
    @author_email = author_email
    @title = title
    @body = body
    @semester = semester # "200(8|9) (Spring|Fall)"
  end
  def self.all
    @all ||= []
  end
end

# Define a method to handle unescaping the escape characters
def unescape_escapes(s)
  s = s.gsub("\\\\", "\\") #Backslash
  s = s.gsub('\\"', '"')   #Double quotes
  s = s.gsub("\\'", "\'")  #Single quotes
  s = s.gsub("\\a", "\a")  #Bell/alert
  s = s.gsub("\\b", "\b")  #Backspace
  s = s.gsub("\\r", "\r")  #Carriage Return
  s = s.gsub("\\n", "\n")  #New Line
  s = s.gsub("\\s", "\s")  #Space
  s = s.gsub("\\t", "\t")  #Tab
  s
end

File.open('problemchilddb.sql') do |f|
  f.each_line do |line|
    if line =~ /INSERT INTO `Entries`/
      line.scan(%r{\(.*?NULL\)}) do |entry_as_string|
        begin
          entry_as_string = entry_as_string.encode(
            'ISO-8859-1',
            :newline => :universal,
            :fallback => {
              "€" => "\x80".force_encoding('ISO-8859-1'),
              "™" => "\x99".force_encoding('ISO-8859-1'),
              "˜" => "\x98".force_encoding('ISO-8859-1'),
              "”" => "\x94".force_encoding('ISO-8859-1'),
              "“" => "\x93".force_encoding('ISO-8859-1'),
              "œ" => "\x9c".force_encoding('ISO-8859-1'),
              "\u009D" => "\xfd".force_encoding('ISO-8859-1'),
            }

          ).force_encoding('UTF-8')
          entry_as_string = unescape_escapes(entry_as_string)
          entry_params = entry_as_string.scan(/'(.*?)',/m).flatten
        rescue Encoding::UndefinedConversionError
          entry_as_string = unescape_escapes(entry_as_string)
          entry_params = entry_as_string.scan(/'(.*?)',/m).flatten
        end
        if entry_params.length == 6
          Entry.all << Entry.new(*entry_params)
        else
          p entry_as_string
          p entry_params
          fail "you're parsing shit badly (you didn't end up with 6 arguments, see above)"
        end
      end # line.scan
    end # if line =~
  end # f.each_line
end # File.open

semesters = Entry.all.group_by(&:semester)
semesters.each do |semester, entries|
  puts "#{semester}: #{entries.count} entries"
end
puts "**total:** #{Entry.all.count}"

magazines = {
  "2008 Spring" => Magazine.find_by_title('Spring 2008'),
  "2008 Fall"   => Magazine.find_by_title('Fall 2008'),
  "2009 Spring" => Magazine.find_by_title('Spring 2009'),
  "2008 Fall"   => Magazine.find_by_title('Fall 2009: Diagnosing the Problem Child')
}

# DATA CLEANUP
Person.find_by_email('mish.irish@facebook.com').try(:update_attribute, :email, 'mishirish@yahoo.com')
Person.find_by_email('jenkach+kylecarrozza4@gmail.com').try(:update_attribute, :email, 'jlk551@psu.edu')
# END DATA CLEANUP

include ActionView::Helpers::TextHelper

Entry.all.each do |entry|
  entry.body  = simple_format(entry.body)
  entry.title = simple_format(entry.title)
  entry.body  = entry.body .gsub(%r{ (&nbsp;)* }, ' \1&nbsp;') while entry.body  =~ %r{ (&nbsp;)* }
  entry.title = entry.title.gsub(%r{ (&nbsp;)* }, ' \1&nbsp;') while entry.title =~ %r{ (&nbsp;)* }
end
Entry.all.each do |entry|
  Submission.create(
    :author => Person.find_or_create("#{entry.author_name}, #{entry.author_email}"),
    :magazine => magazines[entry.semester],
    :title => entry.title,
    :body => entry.body
  )
end


# authors = {}
# Entry.all.each do |entry|
#   if !authors[entry.author_name]
#     authors[entry.author_name] = entry.author_email
#   elsif authors[entry.author_name] != entry.author_email
#     puts "#{authors[entry.author_name]} vs #{entry.author_email}"
#     authors[entry.author_name + " 2"] = entry.author_email
#   end
# end
#
# people = []
# authors.each do |name, email|
#   names = name.split(' ')
#   first, last = names.first, names.last
#   person = Person.find_by_first_name_and_last_name_and_email(first, last, email)
#   if !people.include?(person)
#     people << person
#   else
#     person = Person.find_by_first_name_and_last_name(first, last)
#     if !people.include?(person)
#       # puts "#{person.full_name}'s old email address: #{email}; new email address: #{person.email}"
#       people << person
#     end
#     if !person
#       # these people weren't in the new problemchild system yet; creating them now
#       people << Person.find_or_create("#{name}, #{email}")
#     end
#   end
# end
