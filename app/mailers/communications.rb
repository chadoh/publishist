class Communications < ActionMailer::Base
  default :from => ENV['ADMIN_EMAIL']
  default_url_options[:host] = "problemchildmag.com"

  layout 'notifications'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.communications.newsletter.subject
  #
  def newsletter
    @greeting = "Hi"

    mail :to => "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.communications.weekly_meeting_reminder.subject
  #
  def weekly_meeting_reminder
    @greeting = "Hi"

    mail :to => "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.communications.meeting_notes.subject
  #
  def meeting_notes
    @greeting = "Hi"

    mail :to => "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.communications.contact_person.subject
  #
  def contact_person(to, from, subject, message)
    @topic = subject
    @message = message
    @fromm = from
    @to = to
    mail(
      :from => @fromm.email,
      :to => @to.email,
      :subject => "#{@fromm.name} sent you a message from your profile on Problem Child"
    )
  end
end
