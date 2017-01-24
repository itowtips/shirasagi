SS::Application.routes.draw do

  IjuSupport::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :download do
    get :download, on: :collection
  end

  content "iju_support" do
    get "/" => redirect { |p, req| node_nodes_path }, as: :main
    resources :logins, concerns: :deletion
  end

  node "iju_support" do
    ## login
    match "login/(index.:format)" => "public#login", via: [:get, :post], cell: "nodes/login"
    match "login/login.html" => "public#login", via: [:get, :post], cell: "nodes/login"
    get "login/logout.html" => "public#logout", cell: "nodes/login"
    get "login/:provider/callback" => "public#callback", cell: "nodes/login"
    get "login/failure" => "public#failure", cell: "nodes/login"
  end
end
