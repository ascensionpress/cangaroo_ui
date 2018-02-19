CangarooUI::Engine.routes.draw do
  namespace :cangaroo_ui do
    resources :transactions, only: [:index, :show]
    resources :records, only: [:index, :show, :update]
    resources :retry_jobs, only: [:update]
    resources :resolve_jobs, only: [:update]
    resource  :search, only: [:show]
    resources :errors, only: [:index]
    resources :jobs, only: [:index]
  end
end
