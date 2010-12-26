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
    @author = submission.author
    @url = submission_url(submission)

    mail(
      :to => ENV['EDITOR_EMAIL'],
      :from => submission.email,
      :subject => "Submission: \"#{@title}\" by #{@author}"
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.signup.subject
  #
  def signup(key, person)
    @key = key
    @url = recovery_session_url(@key)
    @person = person

    mail(
      :to => @person.email,
      :subject => "Welcome to Problem Child!"
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.forgot_password.subject
  #
  def forgot_password(key, email)
    @key = key
    @url = recovery_session_url(@key)

    mail(
      :to => email,
      :subject => "Problem Child Password Reset"
    )
  end
end
