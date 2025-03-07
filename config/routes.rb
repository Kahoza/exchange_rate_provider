Rails.application.routes.draw do
  root "api/v1/exchange_rates#index"

  namespace :api do
    namespace :v1 do
      resources :exchange_rates, only: [ :index, :show ] do
        collection do
          get :convert
          post :convert
        end
      end
    end
  end
end
