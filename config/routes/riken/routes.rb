Rails.application.routes.draw do

  # Riken::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  namespace "riken", path: ".sys" do
    namespace "auth" do
      resources :shibboleths, concerns: :deletion
    end
  end

  namespace "riken", path: ".mypage" do
    namespace "login" do
      # Shibboleth
      get "shibboleth/:id/login" => "shibboleth#login", as: :env
    end
  end
end
