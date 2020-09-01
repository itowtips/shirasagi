Rails.application.routes.draw do

  Tourism::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  concern :copy do
    get :copy, on: :member
    put :copy, on: :member
  end

  concern :lock do
    get :lock, on: :member
    delete :lock, action: :unlock, on: :member
  end

  concern :contains_urls do
    get :contains_urls, on: :member
  end

  content "tourism" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, concerns: [:deletion, :lock, :contains_urls]
    resources :notices, concerns: [:deletion, :lock, :contains_urls]
    resources :maps, only: [:index]
  end

  node "tourism" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "page/rss.xml" => "public#rss", cell: "nodes/page", format: "xml"
    get "notice/(index.:format)" => "public#index", cell: "nodes/notice"
    get "notice/rss.xml" => "public#rss", cell: "nodes/notice", format: "xml"
    get "notice/f-:facility/(index.:format)" => "public#index", cell: "nodes/notice"
    get "notice/f-:facility/rss.xml" => "public#rss", cell: "nodes/notice", format: "xml"
    get "map/(index.:format)" => "public#index", cell: "nodes/map"
  end

  page "tourism" do
    get "page/:filename.:format" => "public#index", cell: "pages/page"
    get "notice/:filename.:format" => "public#index", cell: "pages/notice"
  end

  namespace "tourism", path: ".s:site/tourism" do
    namespace "apis" do
      get "pages" => "pages#index"
    end
  end
end
