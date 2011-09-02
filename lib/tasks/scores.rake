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
    initial_magazine_score_values = Magazine.all.collect do |m|
      { m.to_s => {
        count_of_scores: m.count_of_scores,
        sum_of_scores: m.sum_of_scores
      }}
    end
    duplicates.each(&:destroy)
    final_magazine_score_values = Magazine.all.collect do |m|
      { m.to_s => {
        count_of_scores: m.count_of_scores,
        sum_of_scores: m.sum_of_scores
      }}
    end
    puts "\n#{duplicates.count} duplicate scores have been deleted.\n"
    puts "\nComparison of magazine score values, before & after:\n"
    puts "*Before:* #{p initial_magazine_score_values}\n\n"
    puts "*After:* #{p final_magazine_score_values}\n\n"
  end
end
