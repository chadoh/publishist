class NotificationsController < ApplicationController
  def new_composition
    @title = "Very Mary"
    @composition_body = "and her infinite taste"
    @author = "Merry Berry"
    @url = "#"
  end
end
