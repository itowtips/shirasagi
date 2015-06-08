SS::Application.routes.draw do
  get '..g:group/', to: 'gws/portal#index', as: :gws_main

  gws "gws" do
    resources :users, only: [:index, :show, :edit, :update]
    resources :roles do
      get :delete, on: :member
    end
  end
  # TODO integrate / (as portal) and gws/roles

  Schedule::Initializer

  gws "schedule" do
    resources :plans do
      get :delete, on: :member
    end
    get "calendar" => "calendar#index"
  end

  # WIP
  #gws "reservation" do
  #  resources :plans
  #end

  Board::Initializer

  gws "board" do
    resources :topics do
      get :delete, on: :member
      namespace :parent, path: ":parent_id", parent_id: /\d+/ do
        resources :comments, except: [:index], controller: '/board/comments' do
          get :delete, on: :member
        end
      end
    end
  end

  gws "share" do
    resources :files do
      get :view, on: :member
      get :thumb, on: :member
      get :download, on: :member
      get :delete, on: :member
    end
  end
end
