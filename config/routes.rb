Rails.application.routes.draw do

  root to: "errors#routing"

  scope Rails.configuration.x.root_path do

    namespace :api do
      namespace :v1 do
        get '/', to: 'entry#index', as: :entry
        get '/profile', to: redirect('/profile.txt'), as: :profile
      end
    end

    scope 'api' do
      get 'v2', to: 'ti_sqlegalize/v2/entries#show', as: :api_v2_entry
    end

    mount TiSqlegalize::Engine, at: 'api'
  end

  match "*path", to: "errors#routing", via: :all
end
