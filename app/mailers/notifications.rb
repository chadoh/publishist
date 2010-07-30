class Notifications < ActionMailer::Base
  default :from => "admin@problemchildmag.com"
  default_url_options[:host] = "pcmag.heroku.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.new_composition.subject
  #
  def new_composition(composition)
    @title = composition.title
    @composition_body = composition.body # using @body causes problems
    @author = composition.author
    @url = composition_url(composition)

    @green = "#8daf25"
    @blue = "#8bc7c7"
    @font_family = "'Helvetica Neue', Arial, Helvetica, sans-serif"

    mail(:to => "admin@problemchildmag.com",
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
  def forgot_password
    @greeting = "Hi"

    mail :to => "to@example.org"
  end
end
