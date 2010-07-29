class NotificationsController < ApplicationController
  def new_composition
    @title = "Very Mary"
    @composition_body = "and her infinite taste"
    @author = "Merry Berry"
    @url = "#"

    @green = "#8daf25"
    @blue = "#8bc7c7"
    @font_family = "'Helvetica Neue', Arial, Helvetica, sans-serif"
  end
end
