SS::Application.routes.draw do

  Circle::Initializer

  concern :deletion do
    get :delete, on: :member
  end

  content "circle" do
    get "/" => "main#index", as: :main
    resources :pages, concerns: :deletion
    resources :nodes, concerns: :deletion
    resources :locations, concerns: :deletion
    resources :categories, concerns: :deletion

    resources :images, concerns: :deletion
  end

  node "circle" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "node/(index.:format)" => "public#index", cell: "nodes/node"
    get "category/(index.:format)" => "public#index", cell: "nodes/category"
    get "location/(index.:format)" => "public#index", cell: "nodes/location"

    get "search/(index.:format)" => "public#index", cell: "nodes/search"
    get "search/(result.:format)" => "public#result", cell: "nodes/search"
  end

  page "circle" do
    get "image/:filename.:format" => "public#index", cell: "pages/image"
  end

  namespace "circle", path: ".:site/circle" do
    get "/search_categories" => "search_categories#index"
    post "/search_categories" => "search_categories#search"
    get "/search_locations" => "search_locations#index"
    post "/search_locations" => "search_locations#search"
  end

  namespace "circle", path: ".u:user/circle", module: "circle", user: /\d+/ do
    resources :temp_files, concerns: :deletion do
      get :select, on: :member
      get :view, on: :member
      get :thumb, on: :member
      get :download, on: :member
    end
  end
end
