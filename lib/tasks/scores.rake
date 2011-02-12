namespace :db do

  desc "Remove duplicate scores (scores that share a packlet and attendee)"
  task :scores => [:environment] do
    duplicates = []
    scores = Score.order('packlet_id').order('attendee_id')
    scores.each_with_index do |s, i|
      next_score     = scores[i+1] unless i == scores.size - 1
      if next_score.try(:packlet_id) == s.packlet_id && next_score.try(:attendee_id) == s.attendee_id
        duplicates << s
      end
    end
    puts "\n#{duplicates.count} duplicate scores have been deleted.\n"
    duplicates.each(&:destroy)
  end
end
