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
    @user && @user.editor?
  end

  def the_editor?
    @user && @user.the_editor?
  end

  def the_coeditor?
    @user && @user.the_coeditor?
  end

  def staff?
    @user && @user.is_staff?
  end
end
