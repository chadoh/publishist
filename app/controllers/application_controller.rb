class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :reset_return_to_maybe
  before_filter :find_publication

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

  protected

    def must_orchestrate *args
      unless person_signed_in? && current_person.orchestrates?(*args)
        flash[:notice] = "You're not allowed to see that"
        redirect_to root_url and return
      end
    end

    def must_score *args
      unless person_signed_in? && current_person.scores?(*args)
        flash[:notice] = "You're not allowed to see that."
        redirect_to root_url
      end
    end

    def must_view *args
      unless person_signed_in? && current_person.views?(*args)
        flash[:notice] = "You're not allowed to see that."
        redirect_to root_url
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

    def css_display_for_tips
      if @tips && current_person.show_tips_at_page_load
        "block"
      else
        "none"
      end
    end

end
