Rails.application.routes.draw do
  Pippi::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  concern :download_all do
    match :download_all, on: :collection, via: %i[get post]
  end

  concern :import do
    match :import, on: :collection, via: %i[get post]
  end

  content "pippi" do
    get "/" => redirect { |p, req| "#{req.path}/main" }, as: :main
    resources :main, only: :index

    get "tips" => "tips#index"
    resources :tips, path: "tips/:ymd", concerns: [:deletion, :download_all, :import]
    resources :tips_layouts, concerns: [:deletion]
    resources :skill_jsons, concerns: [:deletion]
  end

  node "pippi" do
    get "tips/(index.:format)" => "public#index", cell: "nodes/tips"
    get "tips/:ymd/(index.:format)" => "public#index", cell: "nodes/tips", ymd: /\d{8}/
    get "skill_json/(index.:format)" => "public#index", cell: "nodes/skill_json"
  end

  part "pippi" do
    get "tips" => "public#index", cell: "parts/tips"
    get "event_search" => "public#index", cell: "parts/event_search"
  end
end
