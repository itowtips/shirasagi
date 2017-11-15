SS::Application.routes.draw do
  Gws::Discussion::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :plans do
    get :events, on: :collection
    get :print, on: :collection
    get :popup, on: :member
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :todos do
    get :finish, on: :member
    get :revert, on: :member
    post :finish_all, on: :collection
    post :revert_all, on: :collection
    get :disable, on: :member
    post :disable_all, on: :collection
  end

  gws 'discussion' do
    get '/' => redirect { |p, req| "#{req.path}/topics" }, as: :main

    resources :topics, concerns: [:deletion] do
      resources :comments, concerns: [:deletion] do
        put :reply, on: :member
      end
      resources :todos, concerns: [:plans, :todos ]
    end
  end
end
