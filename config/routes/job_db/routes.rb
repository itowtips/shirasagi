SS::Application.routes.draw do

  JobDb::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :download do
    get :download, on: :collection
  end

  namespace "job_db", path: ".jobdb" do
    get "/" => "main#index", as: :main
    resources :members, concerns: [ :deletion, :download ]
    namespace "member" do
      resources :kinds, concerns: :deletion
    end

    namespace "company" do
      resources :profiles, concerns: :deletion
      resources :calls, concerns: :deletion
      resources :sectors, concerns: :deletion
      resources :areas, concerns: :deletion
    end
  end
end
