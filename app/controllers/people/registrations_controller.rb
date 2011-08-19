class People::RegistrationsController < Devise::RegistrationsController

  def create
    if recaptcha_valid?
      super
    else
      build_resource
      clean_up_passwords(resource)
      flash[:notice] = "You might not be a human. Please try this new captcha below."
      render 'devise/registrations/new'
    end
  end
end
