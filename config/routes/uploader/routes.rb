SS::Application.routes.draw do

  Uploader::Initializer

  concern :deletion do
    get :delete, :on => :member
  end

  concern :directory do
    get :new_directory, :on => :collection
    post :create_directory, :on => :collection
  end

  content "uploader" do
    get "/" => redirect { |p, req| "#{req.path}/files" }, as: :main

    get "files" => "files#index"
    get "files/new" => "files#new"
    get "files/new_directory" => "files#new_directory"
    post "files" => "files#create"
    post "files/create_directory" => "files#create_directory"
    get "files/.:filename" => "files#show", filename: /[^\/]+/
    get "files/.:filename/edit" => "files#edit", filename: /[^\/]+/
    get "files/.:filename/delete" => "files#delete", filename: /[^\/]+/
    put "files/.:filename" => "files#update", filename: /[^\/]+/
    delete "files/.:filename" => "files#destroy", filename: /[^\/]+/

    namespace "file", path: ".:filename", filename: /[^\/]+/ do
      get "files" => "files#index"
      get "files/new" => "files#new"
      get "files/new_directory" => "files#new_directory"
      post "files" => "files#create"
      post "files/create_directory" => "files#create_directory"
      get "files/show" => "files#show"
      get "files/edit" => "files#edit"
      get "files/delete" => "files#delete"
      put "files" => "files#update", filename: /[^\/]+/
      delete "files" => "files#destroy", filename: /[^\/]+/
    end
  end

  node "uploader" do
    get "file/(index.:format)" => "public#index", cell: "nodes/file"
  end

end
