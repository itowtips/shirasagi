SS::Application.routes.draw do

  Board::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, :on => :collection
  end

  concern :download do
    get :download, :on => :collection
  end

  concern :reply do
    get :new_reply, on: :member
    post :reply, on: :member
  end

  # Google Person Finder
  concern :gpf do
    get :gpf, action: :edit_gpf, on: :member
    post :gpf, action: :update_gpf, on: :member
  end

  content "board" do
    get "/" => redirect { |p, req| "#{req.path}/posts" }, as: :main
    resources :posts, concerns: [:deletion, :download, :reply]
    resources :anpi_posts, concerns: [:deletion, :download, :gpf]
  end

  node "board" do
    get "post/(index.:format)" => "public#index", cell: "nodes/post"
    get "post/new" => "public#new", cell: "nodes/post"
    get "post/sent" => "public#sent", cell: "nodes/post"
    post "post/create" => "public#create", cell: "nodes/post"
    get "post/:parent_id/new" => "public#new_reply", cell: "nodes/post"
    post "post/:parent_id/create" => "public#reply", cell: "nodes/post"
    get "post/:parent_id/delete" => "public#delete", cell: "nodes/post"
    delete "post/:parent_id/destroy" => "public#destroy", cell: "nodes/post"

    get "post/search" => "public#search", cell: "nodes/post"

    get "anpi_post/(index.:format)" => "public#index", cell: "nodes/anpi_post"
    get "anpi_post/new" => "public#new", cell: "nodes/anpi_post"
    post "anpi_post/create" => "public#create", cell: "nodes/anpi_post"
    get "anpi_post/search" => "public#search", cell: "nodes/anpi_post"
    post "anpi_post/search" => "public#search", cell: "nodes/anpi_post"
  end

end
