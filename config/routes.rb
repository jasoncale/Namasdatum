Namasdatum::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}
  
  as :user do
    get "foursquare_callback", :to => "registrations#foursquare_callback"
  end
  
  resources :lessons
  resources :users

  match 'design-test' => 'pages#design'

  root :to => "pages#index"
end
