Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      get '/', to: 'entry#index'
      get '/profile', to: redirect('/profile.txt')
    end
  end

  mount TiSqlegalize::Engine, at: '/api/v1'

  match "*path", to: "errors#routing", via: :all
end
