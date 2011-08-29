Pc::Application.routes.draw do

  devise_for :people, controllers: { sessions: 'people/sessions', registrations: 'people/registrations' } do
    get "sign_in", to: "people/sessions#new", as: "sign_in"
    get "sign_up", to: "devise/registrations#new"
  end
  get "submit" => "submissions#new", :as => :new_submission

  get "welcome/index"

  resources :roles, only: [:new, :create, :destroy]
  resources :positions, :scores, :cover_arts, :editors_notes, except: :index
  resources :table_of_contents, :staff_lists, only: [:create, :destroy]

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
  resources :people, shallow: true do
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

  #testing emails
  get "notifications/new_submission"

  resources :magazines do
    member do
      get 'highest_scores', :as => 'highest_scored_for'
      post :publish
      post :notify_authors_of_published_magazine, as: "notify_authors_of_published"
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
