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
  
  
  ##API
  
  get '/API/v1.0/index', to: 'submissions#index_api'
  get '/API/v1.0/upvoted', to: 'submissions#upvoted_api'
  get '/API/v1.0/submissions/ask', to: 'submissions#ask_api'
  post '/API/v1.0/submissions/create_submission', to: 'submissions#post_submission_api'
  put '/API/v1.0/submissions/:id/edit', to: 'submissions#update_api'
  delete '/API/v1.0/submissions/:id/delete', to: 'submissions#delete_api'
  put '/API/v1.0/submissions/upvote/:id', to: 'submissions#upvote_api'
  put '/API/v1.0/submissions/unvote/:id', to: 'submissions#unvote_api'
 
  get '/API/v1.0/user/:id/submissions', to: 'submissions#submitted_api'
  get '/API/v1.0/user/upvoted_submissions', to: 'submissions#upvoted_api'
  
  root to: 'submissions#index'
  
end
