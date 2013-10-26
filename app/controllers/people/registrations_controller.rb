require 'honey_pot'

class People::RegistrationsController < Devise::RegistrationsController

  def new
    build_resource {}
    resource.primary_publication_id = @publication.id
    resource.extend HoneyPot
    respond_with self.resource
  end

  def create
    remove_blank_attributes
    super
  rescue ActiveModel::MassAssignmentSecurity::Error
    redirect_to :root
  end

  def after_update_path_for(resource)
    person_url(resource, subdomain: @publication.subdomain)
  end

  private

  def remove_blank_attributes
    params[:person] = params[:person].reject{|k,v| v.blank? }
  end

end
