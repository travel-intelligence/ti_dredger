Rails.application.routes.draw do

  scope Rails.configuration.x.root_path do

    scope module: :api do
      scope module: :v1 do
        get '/', to: 'entry#index', as: :api_v1_entry
        get '/profile', to: redirect('/profile.txt'), as: :api_v1_profile
      end
    end

    get 'v2', to: 'ti_sqlegalize/v2/entries#show', as: :api_v2_entry

    mount TiSqlegalize::Engine, at: '/'
  end

  root to: "errors#routing"

  match "*path", to: "errors#routing", via: :all
end
