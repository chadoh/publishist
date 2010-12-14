class People::SessionsController < Devise::SessionsController

  def create
    email, password = params[:person][:email], params[:person][:password]
    if person = Person.find_by_email_and_password(email, password)
      logger.info "INFO: Updating #{person.name} to use Devise..."
      if person.verified?
        person.confirm!
        logger.info "INFO: #{person.name} is now confirmed"
      end
      person.update_attributes :password => password,
                               :password_confirmation => password
      logger.info "INFO: #{person.name} now has a Devise-created password_salt and encrypted_password\n"
    end
    super
  end

end
