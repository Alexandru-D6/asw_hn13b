Rails.application.routes.draw do
  resources :comments
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  
  
  resources :submissions do
    member do
      put 'upvote'
    end
  end
  
  resources :submissions do
    member do
      put 'unvote'
    end
  end
  
  resources :submissions do
    member do
      put 'soft_delete'
    end
  end
  
  resources :comments do
    member do
      put 'soft_delete'
    end
  end

  
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  get 'news', to: 'submissions#index'
  get 'newest', to: 'submissions#newest'
  get 'submit', to: 'submissions#new'
  get 'past', to: 'submissions#past'
  get 'ask', to: 'submissions#ask'
  get 'item', to: 'submissions#item'
  get 'user', to: 'users#show'
  get 'reply', to: 'comments#reply'
  get 'delete_comment', to: 'comments#delete'
  get 'deleted_comment', to: 'comments#deleted_comment'
  get 'threads', to: 'comments#threads'
  
  get 'upvoted', to: 'submissions#upvoted'
  get 'upvoted_comments', to: 'comments#upvoted'
  get 'submitted', to: 'submissions#submitted'
  
  root to: 'submissions#index'
  
end
