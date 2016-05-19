SS::Application.routes.draw do

  Urgency::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, :on => :collection
  end

  concern :lock do
    get :lock, :on => :member
    delete :lock, action: :unlock, :on => :member
  end

  content "urgency" do
    get "/" => redirect { |p, req| "#{req.path}/layouts" }, as: :main
    resources :layouts, only: [:index, :show, :update]
    resources :errors, only: :show
    resources :pages, concerns: [:deletion, :lock]
  end

  node "urgency" do
    get "layout/(index.html)" => "public#empty", cell: "nodes/layout"
    get "layout/layout-:layout.html" => "public#index", cell: "nodes/layout", layout: /\d+/

    get "page/(index.html)" => "public#index", cell: "nodes/page"
  end

  page "urgency" do
    get "page/:filename.:format" => "public#index", cell: "pages/page"
  end

  part "urgency" do
    get "page" => "public#index", cell: "parts/page"
  end

end
