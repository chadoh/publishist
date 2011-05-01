namespace :db do

  desc "Assign existing submissions to states"
  task :states => [:environment] do
    puts "\nThere were #{Submission.where(:state => Submission.state(:draft)).count} Drafts,",
         "#{Submission.where(:state => Submission.state(:submitted)).count} Submitted,",
         "#{Submission.where(:state => Submission.state(:queued)).count} Queued,",
         "#{Submission.where(:state => Submission.state(:reviewed)).count} Reviewed,",
         "and #{Submission.where(:state => Submission.state(:scored)).count} Scored submissions.",
         "(Out of a total #{Submission.count} submissions.)\n"

    Submission.where(:state ^ Submission.state(:published), :state ^ Submission.state(:rejected)).each do |sub|
      if sub.packlets.empty?
        sub.update_attribute :state, :submitted
      elsif sub.packlets.select {|p| p.scores.empty?}.present?
        if sub.packlets.select {|p| p.meeting.datetime < Time.now + 3.hours}.empty?
          sub.update_attribute :state, :queued
        else
          sub.update_attribute :state, :reviewed
        end
      else
        sub.update_attribute :state, :scored
      end
    end

    puts "\nThere are now #{Submission.where(:state => Submission.state(:draft)).count} Drafts,",
         "#{Submission.where(:state => Submission.state(:submitted)).count} Submitted,",
         "#{Submission.where(:state => Submission.state(:queued)).count} Queued,",
         "#{Submission.where(:state => Submission.state(:reviewed)).count} Reviewed,",
         "and #{Submission.where(:state => Submission.state(:scored)).count} Scored submissions.",
         "(Out of a total #{Submission.count} submissions.)\n"
  end
end
