Rails.application.routes.draw do

  DesignBook::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  concern :copy do
    get :copy, on: :member
    put :copy, on: :member
  end

  concern :move do
    get :move, on: :member
    put :move, on: :member
  end

  concern :lock do
    get :lock, on: :member
    delete :lock, action: :unlock, on: :member
  end

  concern :command do
    get :command, on: :member
    post :command, on: :member
  end

  concern :contains_urls do
    get :contains_urls, on: :member
  end

  content "design_book" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, concerns: [:deletion, :copy, :move, :lock, :command, :contains_urls]
  end

  node "design_book" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
  end

  part "design_book" do
    get "search" => "public#index", cell: "parts/search"
  end

  page "design_book" do
    get "page/:filename.:format" => "public#index", cell: "pages/page"
  end

end
