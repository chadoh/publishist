class NotificationsController < ApplicationController
  def new_submission
    @submission = Submission.first
    @title = @submission.title
    @submission_body = @submission.body
    @author = @submission.author_name
    @url = "#"

    @heading_image = "http://pcmag.heroku.com/images/mail/heading1.jpg"
    @green = "#8daf25"
    @blue = "#8bc7c7"
    @font_family = "'Helvetica Neue', Arial, Helvetica, sans-serif"
  end
end
