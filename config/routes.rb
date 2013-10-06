Pc::Application.routes.draw do

  as :person do
    put "/person/confirmation" => "confirmations#update", as: :update_user_confirmation
  end

  devise_for :people, controllers: {
    sessions: "people/sessions",
    registrations: "people/registrations",
    confirmations: "confirmations"
  } do
    get "sign_in", to: "people/sessions#new", as: "sign_in"
    get "sign_up", to: "people/registrations#new"
  end

  resources :people, except: [:index, :new] do
    member { post "contact" }
    collection { get "autocomplete" }
  end

  constraints subdomain: /.+/ do
    resources :roles, only: [:new, :create, :destroy]
    resources :scores, only: [:create, :update, :destroy]
    resources :positions, :editors_notes, except: :index
    resources :cover_arts, :table_of_contents, :staff_lists, only: [:create, :destroy]

    resources :meetings do
      resources :attendees, only: [:create, :edit, :update, :destroy] do
        member { put "update_answer" => :update_answer, :as => "update_answer_for" }
      end
      member { get  "scores" => :scores, :as => "scores_for" }
    end

    resources :packlets, only: [:create, :destroy] do
      member { put "update_position" }
    end

    resources :magazines do
      member do
        get "highest_scores", as: "highest_scored_for"
        get "staff_list", as: "staff_for"
        post :publish
        post :notify_authors_of_published_magazine, as: "notify_authors_of_published"
      end
    end
    resources :magazines, only: [] do
      resources :pages, path: "pages", only: [:create]
      resources :pages, path: "", only: [:show, :update, :destroy] do
        member do
          put :add_submission
        end
      end
    end

    get "submit" => "submissions#new", as: "new_submission"
    resources :submissions, path: "submissions", only: [:index, :create]
    resources :submissions, path: "", except: [:index, :create], path_names: { :new => "/submit" }


    get "" => "publications#show", as: "publication"
  end # subdomain

  resources :publications, except: [:index, :show]
  get "" => "publications#index", as: "publications"
  root to: "publications#index"
end
