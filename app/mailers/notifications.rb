class Notifications < ActionMailer::Base
  default :from => "admin@problemchildmag.com"
  default_url_options[:host] = "pcmag.heroku.com"

  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.new_composition.subject
  #
  def new_composition(composition)
    @composition = composition
    @title = composition.title
    @composition_body = composition.body # using @body causes problems
    @author = composition.author
    @url = composition_url(composition)

    mail(
      :to => "editor@problemchildmag.com",
      :from => composition.author_email,
      :subject => "Submission: \"#{@title}\" by #{@author}"
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.signup.subject
  #
  def signup
    @greeting = "Hi"

    mail :to => "to@example.org"
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
