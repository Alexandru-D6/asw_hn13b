Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  
  
  resources :submissions do
    member do
      put 'upvote'
    end
  end
  
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  get 'news', to: 'submissions#index'
  get 'newest', to: 'submissions#index', newest: 'true'
  get 'submit', to: 'submissions#new'
  get 'past', to: 'submissions#past'
  get 'ask', to: 'submissions#ask'
  get 'item', to: 'submissions#item'
  get 'user', to: 'users#show'
  
  root to: 'submissions#index'
  
end
