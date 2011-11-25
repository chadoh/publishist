class HenceforthEverySubmissionShallBelongToAnAccountHolder < ActiveRecord::Migration
  class IncompleteTransition < StandardError; end
  def up
    puts "There are #{Submission.where(author_id: nil).count} submissions without authors. Fixing that..."
    Submission.find_each do |sub|
      unless sub.author_id
        author = Person.where("lower(email) = ?", sub[:author_email].downcase).first
        author ||= Person.create(
                     name: sub[:author_name],
                     email: sub[:author_email]
                   )
        pseudonym = sub[:author_name] if author.name != sub[:author_name]
        sub.author = author
        sub.pseudonym_name = pseudonym
      end
      sub.save
    end
    if !(subs = Submission.where(author_id: nil)).empty?
      raise IncompleteTransition, "Failure! There are still #{subs.count} submissions without associated authors. :-("
    end
    remove_column :submissions, :author_name
    remove_column :submissions, :author_email
  end

  def down
    add_column :submissions, :author_name, :string
    add_column :submissions, :author_email, :string
  end
end
