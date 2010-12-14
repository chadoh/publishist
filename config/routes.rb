Pc::Application.routes.draw do


  devise_for :people, :controllers => { :sessions => "people/sessions" } do
    get "sign_in", :to => "people/sessions#new"
    get "sign_up", :to => "devise/registrations#new"
  end

  get "welcome/index"

  resources :meetings do
    resources :attendances
  end
  resources :packets do
    member do
      put 'update_position'
    end
  end
  resources :compositions, :path_names => { :new => "/submit" }
  resources :people, :shallow => true do
    resources :ranks
    member do
      post 'make_staff'
      post 'make_coeditor'
      post 'make_editor'
      post 'contact'
    end
    collection do
      get 'auto_complete_for_person_first_name_middle_name_last_name_email'
    end
  end

  #aliases, kind of
  #get "me" => "people#show#1"
  get "sign_up" => "people#new", :as => :new_person
  get "submit" => "compositions#new", :as => :new_composition

  #testing emails
  get "notifications/new_composition"

  root :to => "welcome#index"
end
