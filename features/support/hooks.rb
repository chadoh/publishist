Before do
  require 'factory_girl'
  Dir.glob(File.join(File.dirname(__FILE__), '../../test/factories/*.rb')).each {|f| require f }
end

Before('@editor') do
  @user = Factory.create(:current_editor).person
  visit '/sign_in'
  fill_in 'Email', :with => @user.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Before('@coeditor') do
  @user = Factory.create(:current_coeditor).person
  visit '/sign_in'
  fill_in 'Email', :with => @user.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

#Around('@editor', '@coeditor') do |block|
  #@user = Factory.create(:current_editor).person
  #visit '/sign_in'
  #fill_in 'Email', :with => @user.email
  #fill_in 'Password', :with => 'secret'
  #click_button 'Sign In'

  #block.call

  #click_button "Sign out"
  #@user.destroy
  #@user = Factory.create(:current_coeditor).person
  #visit '/sign_in'
  #fill_in 'Email', :with => @user.email
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
