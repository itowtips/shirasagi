SS::Application.routes.draw do

  Circle::Initializer

  concern :deletion do
    get :delete, on: :member
  end

  content "circle" do
    get "/" => redirect { |p, req| "#{req.path}/searches" }, as: :main
    resources :pages, concerns: :deletion
    resources :nodes, concerns: :deletion
    resources :searches, concerns: :deletion
    resources :locations, concerns: :deletion
    resources :categories, concerns: :deletion

    resources :images, concerns: :deletion
    resources :maps, concerns: :deletion
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
    get "map/:filename.:format" => "public#index", cell: "pages/map"
  end

  namespace "circle", path: ".:site/circle" do
    namespace "apis" do
      get "categories" => "categories#index"
      get "locations" => "locations#index"
    end
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
