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
  
  #User
  put '/API/v1.0/users', to: 'users#edit_api'
  get '/API/v1.0/users/upvotedComments', to: 'comments#upvoted_api'
  get '/API/v1.0/users/upvotedSubmissions', to: 'submissions#upvoted_api'
  get '/API/v1.0/users/:name', to: 'users#show_api'
  get '/API/v1.0/users/:name/comments', to: 'comments#threads_api'
  get '/API/v1.0/users/:name/submissions', to: 'submissions#submitted_api'
  
  
  #submission
  get '/API/v1.0/submissions/news' => 'submissions#news_api'
  get '/API/v1.0/submissions/newest', to: 'submissions#newest_api'
  get '/API/v1.0/submissions/ask', to: 'submissions#ask_api'
  post '/API/v1.0/submissions', to: 'submissions#create_api'
  get '/API/v1.0/submissions/:id' => 'submissions#find_submission_api'
  put '/API/v1.0/submissions/:id' => 'submissions#update_api'
  delete '/API/v1.0/submissions/:id/delete', to: 'submissions#delete_api'
  put '/API/v1.0/submissions/:id/upvote', to: 'submissions#upvote_api'
  put '/API/v1.0/submissions/:id/unvote', to: 'submissions#unvote_api'
  
  #comments
  post '/API/v1.0/submissions/:id_submission/comments', to: 'comments#create_api'
  get '/API/v1.0/submissions/:id_submission/comments/:id', to: 'comments#show_api'
  delete '/API/v1.0/submissions/:id_submission/comments/:id', to: 'comments#soft_delete_api'
  put '/API/v1.0/submissions/:id_submission/comments/:id', to: 'comments#edit_api'
  put '/API/v1.0/submissions/:id_submission/comments/:id/upvote', to: 'comments#upvote_api'
  put '/API/v1.0/submissions/:id_submission/comments/:id/unvote', to: 'comments#unvote_api'
  
  root to: 'submissions#index'
  
end
