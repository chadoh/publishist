class Notifications < ActionMailer::Base
  default :from => ENV['ADMIN_EMAIL']
  default_url_options[:host] = "problemchildmag.com"

  helper :application
  include ActionView::Helpers::SanitizeHelper

  def submitted_while_not_signed_in(submission)
    @title           = submission.title
    @author_email    = submission.author_email
    @profile_url     = person_url(submission.author)
    @editor          = Person.current_communicators.first

    mail(
      :to       => @author_email,
      :from     => "#{@editor.try(:name)} <#{ENV['ADMIN_EMAIL'] || "admin@problemchildmag.com"}>",
      :reply_to => @editor.try(:email) || ENV['EDITOR_EMAIL'],
      :subject  => "Someone (hopefully you!) submitted to Problem Child for you!"
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
    @submission = submission
    @title = submission.title
    @submission_body = submission.body # using @body causes problems
    @author = submission.author_name
    @url = submission_url(submission)

    mail(
      :to       => Person.current_communicators.first.try(:email) || ENV['EDITOR_EMAIL'],
      :from     => "#{submission.author_name} <#{ENV['ADMIN_EMAIL'] || "admin@problemchildmag.com"}>",
      :reply_to => submission.email,
      :subject  => "Submission: \"#{strip_tags(@title)}\" by #{@author}"
    ) do |format|
      format.text
      format.html
    end
  end

  def we_published_a_magazine(interested_individuals_email, magazine, array_of_her_submissions = [])
    @email = interested_individuals_email
    @magazine = magazine
    @published = array_of_her_submissions.select{|s| s.state == :published }
    @rejected  = array_of_her_submissions.select{|s| s.state == :rejected }
    editor = Person.current_communicators.first

    mail(
      :to => @email,
      :from => "#{editor.try(:name) || "The Editor"} <admin@problemchildmag.com>",
      :reply_to => editor.try(:email) || "editor@problemchildmag.com",
      :subject => "Problem Child published a magazine!"
    ) do |format|
      format.text
      format.html
    end
  end

  def we_published_a_magazine_a_while_ago(interested_individuals_email, magazine, array_of_her_submissions = [])
    @email = interested_individuals_email
    @magazine = magazine
    @published = array_of_her_submissions.select{|s| s.state == :published }
    @rejected  = array_of_her_submissions.select{|s| s.state == :rejected }
    editor = Person.current_communicators.first

    mail(
      :to => @email,
      :from => "#{editor.try(:name) || "The Editor"} <admin@problemchildmag.com>",
      :reply_to => editor.try(:email) || "editor@problemchildmag.com",
      :subject => "Problem Child's \"#@magazine\" can now be viewed online!"
    ) do |format|
      format.text
      format.html
    end
  end
end
