Encoding.default_external = 'ISO-8859-1'

class Entry
  @@entries = []
  def initialize(id, author_name, author_email, title, body, semester, packet, number, date_of_submission, *crap)
    @author_name = author_name
    @author_email = author_email
    @title = title
    @body = body
    @issue = semester # "200(8|9) (Spring|Fall)"
  end
  def self.create_entries(str)
    str.match(%r{\((.*?)\)}).captures.each do |entry_as_string|
      @@entries << entry_as_string.split(',')
    end
    p @@entries.first
  end
end

File.open('problemchilddb.sql') do |f|
  f.each_line do |line|
    Entry.create_entries(line.encode('ISO-8859-1')) if line =~ /INSERT INTO `Entries`/
  end
end
