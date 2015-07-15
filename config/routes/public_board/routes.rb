SS::Application.routes.draw do

  PublicBoard::Initializer

  concern :deletion do
    get :delete, on: :member
  end

  content "public_board" do
    get "/" => redirect { |p, req| "#{req.path}/topics" }, as: :main
    get "generate" => "generate#index"
    post "generate" => "generate#run"
    resources :topics, concerns: :deletion
  end

  node "public_board" do
    get "topic/(index.:format)" => "public#index", cell: "nodes/topic"
    get "topic/new(index.:format)" => "public#new", cell: "nodes/topic"
    post "topic/" => "public#create", cell: "nodes/topic"
  end

end
