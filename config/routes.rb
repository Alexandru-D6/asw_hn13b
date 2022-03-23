Rails.application.routes.draw do
  resources :submissions
  
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  root 'submissions#index'
  
  get 'newest', to: 'submissions#newest'
  get 'news', to: 'submissions#index'
  
end
