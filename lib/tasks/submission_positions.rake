namespace :db do

  desc "Ensure that all published submissions have a position and no other ones do"
  task :submission_positions => [:environment] do
    shouldnt_have_positions = Submission.where(:state ^ Submission.state(:published), :position ^ nil)
    puts "There were #{shouldnt_have_positions.count} submissions that had positions when they shouldn't have"
    shouldnt_have_positions.update_all position: nil

    Page.all.each do |page|
      page.submissions.each_with_index do |sub, i|
        sub.update_attribute :position, i + 1
      end
    end

    puts "...and you should be all set to reorder submissions on their pages, too!"
  end
end
