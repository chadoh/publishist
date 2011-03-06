module ApplicationHelper
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
        haml_concat " – "
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

  def editor?
    person_signed_in? && current_person.editor?
  end

  def the_editor?
    person_signed_in? && current_person.the_editor?
  end

  def the_coeditor?
    person_signed_in? && current_person.the_coeditor?
  end

  def staff?
    person_signed_in? && current_person.is_staff?
  end
  
  def member?
    person_signed_in?
  end

  def editor_or_author? submission
    person_signed_in? && (the_editor? || current_person == submission.author)
  end

  def coeditor_or_author? submission
    person_signed_in? && (the_coeditor? || current_person == submission.author)
  end

  def page_appropriate?
    !current_page?(:controller => "submissions", :action => "index") and !current_page?(:controller => "meetings", :action => "show")
  end
end
