SS::Application.routes.draw do

  JobDb::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :download do
    get :download, on: :collection
  end

  get '.jobdb/', to: 'job_db/portal#index', as: :job_db_portal

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

    namespace "incident" do
      resources :topics, concerns: :deletion do
        resources :comments, concerns: :deletion
      end
      resources :categories, concerns: :deletion
    end

    namespace "apis" do
      get "members" => "members#index"
      get "categories" => "categories#index"
    end
  end

  content "job_db" do
    resources :logins, concerns: :deletion
  end

  node "job_db" do
    ## login
    match "login/(index.:format)" => "public#login", via: [:get, :post], cell: "nodes/login"
    match "login/login.html" => "public#login", via: [:get, :post], cell: "nodes/login"
    get "login/logout.html" => "public#logout", cell: "nodes/login"
    get "login/:provider/callback" => "public#callback", cell: "nodes/login"
    get "login/failure" => "public#failure", cell: "nodes/login"
  end
end
