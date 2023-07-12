Rails.application.routes.draw do
  root to: "dashboard#show"
  get :login, to: "sessions#login"
  get :authenticate, to: "sessions#authenticate"
  resources :sales, only: :index
end
