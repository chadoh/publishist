class NotificationsController < ApplicationController
  def new_composition
    @title = "Very Mary"
    @composition_body = "and her infinite taste"
    @author = "Merry Berry"
    @url = "#"

    @heading_image = "http://pcmag.heroku.com/images/mail/heading1.jpg"
    @green = "#8daf25"
    @blue = "#8bc7c7"
    @font_family = "'Helvetica Neue', Arial, Helvetica, sans-serif"
  end
end
