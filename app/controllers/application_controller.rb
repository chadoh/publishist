class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :reset_return_to_maybe
  before_filter :find_publication
  before_filter :set_tips

  def reset_return_to_maybe
    if session[:return_to]
      session[:return_to_age] ||= 0
      session[:return_to_age] += 1
      if session[:return_to_age] > 1
        session[:return_to] = nil
        session[:return_to_age] = nil
      end
    end
  end

  def find_publication
    @publication = current_publication
  end

  def set_tips
    @tips = PageTips.new("#{params[:controller]}##{params[:action]}", current_person, @show_conditional_tips).tips
  end

  protected

    def must_orchestrate *args
      unless person_signed_in? && current_person.orchestrates?(*args)
        flash[:notice] = "You're not allowed to see that"
        redirect_to root_url(subdomain: @publication.subdomain) and return
      end
    end

    def must_score *args
      unless person_signed_in? && current_person.scores?(*args)
        flash[:notice] = "You're not allowed to see that."
        redirect_to root_url(subdomain: @publication.subdomain)
      end
    end

    def must_view *args
      unless person_signed_in? && current_person.views?(*args)
        flash[:notice] = "You're not allowed to see that."
        redirect_to root_url(subdomain: @publication.subdomain)
      end
    end

    def current_publication
      @publication ||= Publication.find_by_subdomain(request.subdomain)
      @publication ||= Publication.find_by_custom_domain(request.host)
      @publication or not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

end
