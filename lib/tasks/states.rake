namespace :db do

  desc "Assign existing submissions to states"
  task :states => [:environment] do
    puts "\nBefore:",
         "| Draft     | #{Submission.where(:state => Submission.state(:draft)).count}",
         "| Submitted | #{Submission.where(:state => Submission.state(:submitted)).count}",
         "| Queued    | #{Submission.where(:state => Submission.state(:queued)).count}",
         "| Reviewed  | #{Submission.where(:state => Submission.state(:reviewed)).count}",
         "| Scored    | #{Submission.where(:state => Submission.state(:scored)).count}",
         "| *Total*   | #{Submission.count}\n"

    Submission.where("state != ? AND state != ?", Submission.state(:published), Submission.state(:rejected)).each do |sub|
      if sub.state == :draft && sub.author.nil? && sub.packlets.empty?
        sub.update_attribute :state, :submitted
      elsif sub.packlets.present? && sub.scores.empty?
        if sub.packlets.select {|p| p.meeting.datetime < Time.now + 3.hours}.empty?
          sub.update_attribute :state, :queued
        else
          sub.update_attribute :state, :reviewed
        end
      elsif sub.scores.present?
        sub.update_attribute :state, :scored
      end
    end

    puts "\nNow:",
         "| Draft     | #{Submission.where(:state => Submission.state(:draft)).count}",
         "| Submitted | #{Submission.where(:state => Submission.state(:submitted)).count}",
         "| Queued    | #{Submission.where(:state => Submission.state(:queued)).count}",
         "| Reviewed  | #{Submission.where(:state => Submission.state(:reviewed)).count}",
         "| Scored    | #{Submission.where(:state => Submission.state(:scored)).count}",
         "| *Total*   | #{Submission.count}\n"
  end
end
