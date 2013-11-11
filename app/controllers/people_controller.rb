class PeopleController < InheritedResources::Base
  before_filter :only => [:destroy] do |c|
    c.orchestrates @publication
  end
  before_filter :ensure_current_url, :only => :show

  respond_to :js, only: :toggle_default_tips

  skip_before_filter :find_publication, only: :toggle_default_tips

  def autocomplete
    terms = params[:term].split(' ')
    @people = terms.map do |term|
                @publication.people.limit(15).
                  where(
                    "first_name ILIKE :term OR middle_name ILIKE :term
                    OR last_name ILIKE :term OR email ILIKE :term",
                    term: "%#{term}%"
                  )
              end.flatten.uniq.sort do |a,b|
                a.first_name <=> b.first_name
              end.map do |p|
                { :value => "#{p.name}, #{p.email}" }
              end
    respond_to do |wants|
      wants.any { render json: @people }
    end
  end

  def show
    @person = Person.find params[:id]
    @positions_by_issue = @person.positions.reject{|p| p.abilities.collect(&:key).include?('disappears') }\
      .group_by(&:issue).sort_by {|issue, poses| issue.accepts_submissions_from }.reverse
    submissions = @person.submissions
    submissions.reload # fixes weird queued-to-reviewed bug
    @published = submissions.where :state => Submission.state(:published)
    if person_signed_in? && current_person == @person
      @submitted = submissions.where :state => Submission.state(:submitted)
      @queued    = submissions.where :state => Submission.state(:queued)
      @reviewed  = submissions.where :state => Submission.state(:reviewed)
      @scored    = submissions.where :state => Submission.state(:scored)
      @drafts    = submissions.where :state => Submission.state(:draft)
      @rejected  = submissions.where :state => Submission.state(:rejected)
    else
      @published = @published.select{|s| s.pseudonym_link }
    end
  end

  def contact
    @to = Person.find(params[:contact_person][:to])
    @from = Person.find(params[:contact_person][:from])
    @subject = params[:contact_person][:subject]
    @message = params[:contact_person][:message]
    Communications.delay.contact_person(@to, @from, @subject, @message)
    flash[:notice] = "Your message has been sent!"
    redirect_to person_url(@to)
  end

  def toggle_default_tips
    person = Person.find(params[:id])
    person.update_attribute :show_tips_at_page_load, !person.show_tips_at_page_load
    head :ok
  end

protected

  def ensure_current_url
    if request.path != person_path(resource)
      redirect_to resource, :status => :moved_permanently
    end
  end
end
