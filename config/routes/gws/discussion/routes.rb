SS::Application.routes.draw do
  Gws::Discussion::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  gws 'discussion' do
    resources :topics, concerns: [:deletion] do
      resources :comments, concerns: [:deletion] do
        put :reply, on: :member
      end
    end
  end
end
