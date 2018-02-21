CangarooUI::Engine.routes.draw do
  root to: "transactions#index"
  resources :transactions, only: [:index, :show]
  resources :records, only: [:index, :show, :update]
  resources :retry_jobs, only: [:update]
  resources :resolve_jobs, only: [:update]
  resource  :search, only: [:show]
  resources :errors, only: [:index]
  resources :jobs, only: [:index]
end
