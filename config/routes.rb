Rails.application.routes.draw do
  post "/callback" => "webhook#callback"

  get "preview", to: "home#index"
end
