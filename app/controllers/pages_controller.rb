class PagesController < InheritedResources::Base
  actions :show, :create, :update, :destroy
  belongs_to :meeting

  respond_to :html

end
