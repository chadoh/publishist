class Notifications < ActionMailer::Base
  default_url_options[:host] = "publishist.com"

  helper :application
  include ActionView::Helpers::SanitizeHelper

  def submitted_while_not_signed_in(submission)
    @publication     = submission.publication
    @title           = submission.title
    @author_email    = submission.author_email
    @profile_url     = person_url(submission.author, subdomain: @publication.subdomain)
    @editor          = @publication.editor

    mail(
      :to       => @author_email,
      :from     => "#{@editor.try(:name)} <support@publishist.com>",
      :reply_to => @editor.email,
      :subject  => "Someone (hopefully you!) submitted to #{@publication.name} for you!"
    ) do |format|
      format.text
      format.html
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifications.new_submission.subject
  #
  def new_submission(submission)
    @publication = submission.publication
    @submission = submission
    @title = submission.title
    @submission_body = submission.body # using @body causes problems
    @author = submission.author_name
    @url = submission_url(submission, subdomain: @publication.subdomain)

    mail(
      :to       => @publication.editor.email,
      :from     => "#{submission.author_name} <support@publishist.com>",
      :reply_to => submission.email,
      :subject  => "Submission: \"#{strip_tags(@title)}\" by #{@author}"
    ) do |format|
      format.text
      format.html
    end
  end

  def we_published_an_issue(interested_individuals_email, issue, array_of_her_submissions = [])
    @email = interested_individuals_email
    @issue = issue
    @publication = issue.publication
    @published = array_of_her_submissions.select{|s| s.state == :published }
    @rejected  = array_of_her_submissions.select{|s| s.state == :rejected }
    editor = @publication.editor

    mail(
      :to => @email,
      :from => "#{editor.name} <support@publishist.com>",
      :reply_to => editor.email,
      :subject => "#{@publication.name} published a issue!"
    ) do |format|
      format.text
      format.html
    end
  end

  def we_published_an_issue_a_while_ago(interested_individuals_email, issue, array_of_her_submissions = [])
    @email = interested_individuals_email
    @issue = issue
    @publication = issue.publication
    @published = array_of_her_submissions.select{|s| s.state == :published }
    @rejected  = array_of_her_submissions.select{|s| s.state == :rejected }
    editor = @publication.editor

    mail(
      :to => @email,
      :from => "#{editor.name} <support@publishist.com>",
      :reply_to => editor.email,
      :subject => "#{@publication.name}'s \"#@issue\" can now be viewed online!"
    ) do |format|
      format.text
      format.html
    end
  end
end
