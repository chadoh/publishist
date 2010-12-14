class People::SessionsController < Devise::SessionsController

  def create
    #logger.info "INFO: Available params: #{params.keys}"
    email = params["email"]; password = params["password"]
    #logger.info "INFO: Looking for #{email} with the old method..."
    if person = Person.find_by_email_and_password(email, password)
      logger.info "INFO: Updating #{person.name} to use Devise..."
      if person.verified?
        person.confirm!
        logger.info "#{person.first_name} should now be confirmed"
      end
      person.update_attributes :password => password,
                               :password_confirmation => password
      logger.info "#{person.first_name} should now have a Devise-created password_salt and encrypted_password\n"
    end
    super
  end

end
