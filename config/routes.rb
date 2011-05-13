Pc::Application.routes.draw do


  devise_for :people do
    get "sign_in", :to => "people/sessions#new"
    get "sign_up", :to => "devise/registrations#new"
  end

  get "welcome/index"

  resources :scores

  resources :magazines do
    member do
      get 'highest_scores', :as => 'highest_scored_for'
      post :publish
    end
  end

  resources :meetings do
    resources :attendees do
      member { put 'update_answer' => :update_answer, :as => 'update_answer_for' }
    end
    member { get  'scores' => :scores, :as => 'scores_for' }
  end

  resources :packlets do
    member do
      put 'update_position'
    end
  end
  resources :submissions, :path_names => { :new => "/submit" }
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
  get "sign_up" => "people#new", :as => :new_person
  get "submit" => "submissions#new", :as => :new_submission

  #testing emails
  get "notifications/new_submission"

  root :to => "welcome#index"
end
