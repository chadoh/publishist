module ApplicationHelper
  extend ActiveSupport::Memoizable
  include Rack::Recaptcha::Helpers

  def pluralize_phrase(number, singular_phrase, plural_phrase)
    return singular_phrase if number == 1
    return plural_phrase if number > 1
  end
  def email_image(name)
    image_tag('/images/email.png', :title => "Send an email to #{name.split(' ').first}", :alt => "Send email to #{name}")
  end

  def pretty_date(date)
    if date.year != Date.today.year
      date.strftime("%d %b %Y")
    else
      date.strftime("%d %b")
    end
  end

  def timeframe start, finish
    capture_haml do
      haml_tag 'span.timeframe' do
        haml_tag :time, :datetime => start do
          haml_concat pretty_date start
        end
        haml_concat " &ndash; ".html_safe
        haml_tag :time, :datetime => finish do
          haml_concat pretty_date finish
        end
      end
    end
  end

  def error_messages
    if resource.errors.any?
      capture_haml do
        haml_tag "#errorExplanation" do
          haml_tag :h3 do
            haml_concat "There #{pluralize_phrase(resource.errors.count, "was an error", "were some errors")}!"
          end
          haml_tag :ul do
            resource.errors.full_messages.each do |msg|
              haml_tag :li do
                haml_concat msg
              end
            end
          end
        end
      end
    end
  end

  def communicates? *args
    person_signed_in? && current_person.communicates?(*args)
  end

  def orchestrates? *args
    person_signed_in? && current_person.orchestrates?(*args)
  end

  def scores? *args
    person_signed_in? && current_person.scores?(*args)
  end

  def views? *args
    person_signed_in? && current_person.views?(*args)
  end

  def communicates_or_is_author? submission
    person_signed_in? && (communicates?(submission) || current_person == submission.author)
  end

  def scores_or_is_author? submission
    person_signed_in? && (scores?(submission) || current_person == submission.author)
  end

  def page_appropriate?
    @page_appropriate ||= !current_page?(:controller => "submissions", :action => "index") and !(params['controller'] == "meetings" && params['action'] == 'show')
  end

  def current_person_can_see_score_for? submission
    submission.scored? && \
    (
      scores_or_is_author?(submission) || \
      (
        params[:controller] == 'magazines' && \
        params[:action]     == 'highest_scores'))
  end

  memoize :communicates_or_is_author?, :scores_or_is_author?, :current_person_can_see_score_for?
end
