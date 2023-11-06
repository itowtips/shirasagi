Rails.application.routes.draw do

  LineLiff::Initializer

  concern :deletion do
    get :delete, on: :member
  end

  content "line_liff" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, only: [:index]
  end

  node "line_liff" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
  end
end
