Before do
  require 'factory_girl'
  Dir.glob(File.join(File.dirname(__FILE__), '../../test/factories/*.rb')).each {|f| require f }
end

Before('@editor') do
  @editor = Factory.create(:current_editor).person
  visit '/sign_in'
  fill_in 'Email', :with => @editor.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Before('@coeditor') do
  @coeditor = Factory.create(:current_coeditor).person
  visit '/sign_in'
  fill_in 'Email', :with => @coeditor.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

#Around('@editor', '@coeditor') do |block|
  #@editor = Factory.create(:current_editor).person
  #visit '/sign_in'
  #fill_in 'Email', :with => @editor.email
  #fill_in 'Password', :with => 'secret'
  #click_button 'Sign In'

  #block.call

  #click_button "Sign out"
  #@editor.destroy
  #@coeditor = Factory.create(:current_coeditor).person
  #visit '/sign_in'
  #fill_in 'Email', :with => @coeditor.email
  #fill_in 'Password', :with => 'secret'
  #click_button 'Sign In'

  #block.call
#end

Before('@webmember') do
  @user = Factory.create(:person)
  visit '/sign_in'
  fill_in 'Email', :with => @user.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Before('@meetings') do
  Factory.create :meeting
  Factory.create :meeting2
end
