Pc::Application.routes.draw do


  devise_for :people do
    get "sign_in", :to => "people/sessions#new"
    get "sign_up", :to => "devise/registrations#new"
  end

  get "welcome/index"

  resources :scores
  resources :cover_arts,    only: [:update]
  resources :editors_notes, only: [:new, :create, :update]

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

  resources :magazines do
    member do
      get 'highest_scores', :as => 'highest_scored_for'
      post :publish
    end
  end
  resources :magazines, only: [] do
    resources :pages, path: 'pages', only: [:create]
    resources :pages, path: '', except: [:index, :new, :create, :edit] do
      member do
        put :add_submission
      end
    end
  end

  resources :submissions, :path => 'submissions', :only => [:index, :create]
  resources :submissions, :path => '', :except => [:index, :create], :path_names => { :new => "/submit" }

  root :to => "welcome#index"
end
