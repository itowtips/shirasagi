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
      namespace :sector, path: "sector:sector_id", sector_id: /\w+/ do
        resources :sectors, concerns: :deletion
      end

      resources :areas, concerns: :deletion
      namespace :area, path: "area:area_id", area_id: /\w+/ do
        resources :areas, concerns: :deletion
      end

      resources :prefecture_certifications, concerns: :deletion
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
    resources :member_ezines, concerns: :deletion
    resources :inquiry_forms, concerns: :deletion
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
