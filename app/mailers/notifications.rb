class Notifications < ActionMailer::Base
  default :from => ENV['ADMIN_EMAIL']
  default_url_options[:host] = "problemchildmag.com"

  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.new_submission.subject
  #
  def new_submission(submission)
    @submission = submission
    @title = submission.title
    @submission_body = submission.body # using @body causes problems
    @author = submission.author_name
    @url = submission_url(submission)

    mail(
      :to => ENV['EDITOR_EMAIL'],
      :from => submission.email,
      :subject => "Submission: \"#{@title}\" by #{@author}"
    )
  end

end
