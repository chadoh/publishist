class People::RegistrationsController < Devise::RegistrationsController

  def create
    if recaptcha_valid?
      super
    else
      build_resource
      clean_up_passwords(resource)
      flash[:notice] = "You might not be a human. Please try this new captcha below."
      render_with_scope :new
    end
  end

  def after_sign_in_path_for(resource)
    session[:return_to] || person_url(resource)
  end

end
