Rails.application.routes.draw do
  resources :submissions do
    member do
      put 'upvote'
    end
  end
  
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  get 'news', to: 'submissions#index'
  get 'newest', to: 'submissions#index', newest: 'true'
  
  root 'submissions#index'
end
