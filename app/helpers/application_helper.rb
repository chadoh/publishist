module ApplicationHelper
  def pluralize_phrase(number, singular_phrase, plural_phrase)
    return singular_phrase if number == 1
    return plural_phrase if number > 1
  end
  def email_image(name)
    image_tag('/images/email.png', :title => "Send an email to #{name.split(' ').first}", :alt => "Send email to #{name}")
  end

  def pretty_date(date)
    if date < Time.now.years_ago(1)
      date.strftime("%d %b %Y")
    else
      date.strftime("%d %b")
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

  def the_editor_or_the_owner?(compo)
    person_signed_in? && (current_person.the_editor? || current_person.name == compo.author)
  end
end
