class Communications < ActionMailer::Base
  default_url_options[:host] = "people.publishist.com"

  layout 'devise/mailer'

  def contact_person(to, from, subject, message)
    @topic = subject
    @message = message
    @fromm = from
    @to = to
    mail(
      :from     => "#{@fromm.name} <donotreply@publishist.com>",
      :reply_to => @fromm.email,
      :to       => @to.email,
      :subject  => "#{@fromm.name} sent you a message from your profile on Publishist"
    ) do |format|
      format.text
      format.html
    end
  end
end
