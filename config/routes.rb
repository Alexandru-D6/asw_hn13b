Rails.application.routes.draw do
  resources :comments
  resources :users
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
  
  resources :comments do
    member do
      put 'upvote'
    end
  end
  
  resources :submissions do
    member do
      put 'soft_delete'
    end
  end
  
  resources :comments do
    member do
      put 'unvote'
    end
  end

  resources :comments do
    member do
      delete 'soft_delete'
    end
  end

  
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
  
  
  ##API
  
  #submission
  get '/API/v1.0/submission/index', to: 'submissions#index_api'
  get '/API/v1.0/submission/upvoted', to: 'submissions#upvoted_api'
  get '/API/v1.0/submission/newest', to: 'submissions#newest_api'
  
  #comments
  get '/API/v1.0/comment/:id', to: 'comments#show_api'
  post '/API/v1.0/comments', to: 'comments#create_api'
  delete '/API/v1.0/comment/:id', to: 'comments#soft_delete_api'
  
  put '/API/v1.0/comment/:id/upvote', to: 'comments#upvote_api'
  put '/API/v1.0/comment/:id/unvote', to: 'comments#unvote_api'
  
  put '/API/v1.0/comment/:id/edit', to: 'comments#edit_api'
  
  
  #User
  get '/API/v1.0/user/:name', to: 'users#show_api'
  get '/API/v1.0/user/:name/comments', to: 'comments#threads_api'
  get '/API/v1.0/users/voted_comments', to: 'comments#upvoted_api'
  put '/API/v1.0/users/edit', to: 'users#edit_api'
  
  
  
  root to: 'submissions#index'
  
end
