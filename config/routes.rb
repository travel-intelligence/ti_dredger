Rails.application.routes.draw do

  scope Rails.configuration.x.root_path do

    scope module: 'api/v1' do
      get '/', to: 'entry#index', as: :api_v1
      get '/profile', to: redirect('/profile.txt'), as: :api_v1_profile
    end

    mount TiSqlegalize::Engine, at: 'sql'

  end

  match "*path", to: "errors#routing", via: :all
end
