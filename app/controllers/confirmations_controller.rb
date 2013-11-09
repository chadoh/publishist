class ConfirmationsController < Devise::PasswordsController
  skip_before_filter :require_no_authentication
  skip_before_filter :set_tips

  # PUT /person/confirmation
  def update
    with_unconfirmed_person do
      if @person.has_no_password?
        @person.attempt_to_set_password(params[:person])
        if @person.valid?
          do_confirm
        else
          do_show
          @person.errors.clear #so that we wont render :new
        end
      else
        self.class.add_error_on(self, :email, :password_allready_set)
      end
    end

    if !@person.errors.empty?
      render_with_scope :new
    end
  end

  # GET /person/confirmation?confirmation_token=abcdef
  def show
    with_unconfirmed_person do
      if @person.has_no_password?
        do_show
      else
        do_confirm
      end
    end
    if !@person.errors.empty?
      render_with_scope :new
    end
  end

  def new
    super
  end

protected
  def with_unconfirmed_person
    @person = Person.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token].presence || params[:person][:confirmation_token])
    if !@person.new_record?
      @person.only_if_unconfirmed {yield}
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @person
    render_with_scope :show
  end

  def do_confirm
    @person.confirm!
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @person)
  end
end
