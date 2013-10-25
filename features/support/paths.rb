module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /my profile page/i
      "/people/#{@person.reload.to_param}"

    when /([^']*)'s profile page/i
      person = Person.find_by_first_name($1)
      "/people/#{person.to_param}"

    when /the submit page/i
      # "/submit"
      "/submit?submission_agreement=true"

    when /the magazine's cover page/i
      "/magazines/#{Magazine.first.to_param}/#{Page.where(position: 1).first.to_param}"

    when /the magazine's staff page/i
      staff_for_magazine_path(Magazine.first)

    when /page (.*) of the "([^"]*)" magazine/i
      m = Magazine.find_by_nickname $2
      "/magazines/#{m.to_param}/#{$1}"

    when /page (.*) of the magazine/i
      "/magazines/#{Magazine.first.to_param}/#{$1}"

    when /the first (.*) page/i
      model = $1.titleize.constantize
      instance = if model.count > 0
                   model.first
                 else
                   Factory.create(model.to_s.underscore.to_sym)
                 end
      eval "#{model.base_class.to_s.underscore}_path('#{instance.to_param}')"

    when /the "([^"]*)" magazine page/i
      m = Magazine.find_by_nickname $1
      eval "magazine_path('#{m.id}')"

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
