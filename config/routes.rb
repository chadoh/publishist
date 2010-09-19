Pc::Application.routes.draw do

  get "welcome/index"

  resources :meetings, :attendances
  resources :compositions, :path_names => { :new => "/submit" }
  resources :people, :shallow => true do
    resources :ranks
    member do
      post 'make_staff'
      post 'make_coeditor'
      post 'make_editor'
      post 'contact'
      get 'set_password'
    end
    collection do
      get 'help'
      post 'recover'
    end
  end
  resources :sessions, :only => [:new, :create, :destroy] do
    member do
      get 'recovery'
    end
  end

  #aliases, kind of
  #get "me" => "people#show#1"
  get "sign_in" => "sessions#new", :as => :new_session
  get "sign_up" => "people#new", :as => :new_person
  get "submit" => "compositions#new", :as => :new_composition

  #testing emails
  get "notifications/new_composition"

  root :to => "welcome#index"
end
