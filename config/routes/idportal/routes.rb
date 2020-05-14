Rails.application.routes.draw do

  Idportal::Initializer

  content "idportal" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages
    resources :searches
  end

  node "idportal" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "page/result.html" => "public#index", cell: "nodes/page"
    get "search/(index.:format)" => "public#index", cell: "nodes/search"
  end

  part "idportal" do
    get "search" => "public#index", cell: "parts/search"
  end

end
