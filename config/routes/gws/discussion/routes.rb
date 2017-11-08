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

  concern :copy do
    get :copy, on: :member
    put :copy, on: :member
  end

  gws 'discussion' do
    get '/' => redirect { |p, req| "#{req.path}/topics" }, as: :main

    resources :forums, concerns: [:deletion, :copy] do
      resources :topics, concerns: [:deletion, :copy] do
        #get :comments, on: :member
        put :reply, on: :member
        resources :comments, controller: '/gws/discussion/comments', concerns: [:deletion] do
          put :reply, on: :collection
        end
      end
      resources :todos, concerns: [:plans, :todos]
    end
  end
end
