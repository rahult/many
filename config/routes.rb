Rails.application.routes.draw do

  root 'application#index'

  namespace :v1 do
    resources :posts, only: [:index, :show]
    resources :comments, only: [:index, :show]
  end

end
