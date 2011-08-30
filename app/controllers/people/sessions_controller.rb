class People::SessionsController < Devise::SessionsController

  ## For legacy reference only.
  # def create
  #   email, password = params[:person][:email], params[:person][:password]
  #   if person = Person.find_by_email_and_password(email, password)
  #     logger.info "INFO: Updating #{person.name} to use Devise..."
  #     if person.verified?
  #       person.confirm!
  #       logger.info "INFO: #{person.name} is now confirmed"
  #     end
  #     person.update_attributes :password => password,
  #                              :password_confirmation => password
  #     logger.info "INFO: #{person.name} now has a Devise-created password_salt and encrypted_password\n"
  #   end
  #   super
  # end

  def new
    session[:return_to] = request.referer
    super
  end

  def after_sign_in_path_for(resource)
    session[:return_to] || root_url
  end

  def after_sign_out_path_for(resource)
    request.referer || root_url
  end

end
