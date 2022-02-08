Rails.application.routes.draw do
  Gws::Portal::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  concern :portlet do
    get :sync, on: :collection
    post :sync, on: :collection
    get :reset, on: :collection
    post :reset, on: :collection
  end

  concern :file_api do
    get :select, on: :member
    get :selected_files, on: :collection
  end

  gws "portal" do
    resources :presets, concerns: [:deletion] do
      get :sync, on: :collection
      post :sync, on: :collection
      get :reset, on: :collection
      post :reset, on: :collection
    end
    namespace :preset, path: 'p-:preset' do
      resources :portlets, concerns: [:deletion, :portlet]
      resource :settings, concerns: [:deletion], only: [:show, :edit, :update]
      resource :layouts, concerns: [:deletion], only: [:show, :update]
    end

    namespace :user, path: 'u-:user' do
      get '/' => 'portal#show'
      resources :portlets, concerns: [:deletion, :portlet]
      resource :settings, concerns: [:deletion], only: [:show, :edit, :update]
      resource :layouts, concerns: [:deletion], only: [:show, :update]
    end

    namespace :group, path: 'g-:group' do
      get '/' => 'portal#show'
      resources :portlets, concerns: [:deletion, :portlet]
      resource :settings, concerns: [:deletion], only: [:show, :edit, :update]
      resource :layouts, concerns: [:deletion], only: [:show, :update]
    end

    namespace :setting do
      resources :users, only: [:index]
      resources :groups, only: [:index]
    end

    namespace "apis" do
      resources :ad_files, path: 'ads', only: [], concerns: :file_api
    end
  end
end
