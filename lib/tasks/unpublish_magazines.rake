desc "Unpublish all magazines"
task unpublish_magazines: [:environment] do
  puts "Unpublishing all magazines...\n\n"

  Magazine.update_all(
    published_on:      nil,
    notification_sent: false
  )
  Submission.where(state: Submission.state(:published), state: Submission.state(:rejected)).update_all(
    state: Submission.state(:scored)
  )
  Page.destroy_all
  TableOfContents.destroy_all
  StaffList.destroy_all
  EditorsNote.destroy_all
  CoverArt.destroy_all
  Rake::Task['db:states'].invoke

  puts "\n\n...done."
end
