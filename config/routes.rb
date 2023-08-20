Rails.application.routes.draw do
  # In case of we need to make url shorter, we may remove all extra namespaces from url
  namespace :api do
    namespace :v1 do
      resources :url_shortener, only: [:create, :show]
    end
  end
end
