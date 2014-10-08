Rails.application.routes.draw do

  resources :offers, only: [:index] do 
    collection do
      get :list
    end
  end

  root 'offers#index'

end
