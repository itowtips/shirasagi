SS::Application.routes.draw do

  Rss::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, :on => :collection
  end

  concern :import do
    match :import, via: [:get, :post], on: :collection
  end

  content "rss" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, concerns: [:deletion, :import]
    resources :pub_sub_hubbubs, concerns: [:deletion] do
      match :subscribe, via: [:get, :post], on: :collection
      match :unsubscribe, via: [:get, :delete], on: :collection
    end
  end

  node "rss" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"

    get "pub_sub_hubbub/(index.:format)" => "public#index", cell: "nodes/pub_sub_hubbub"
    get "pub_sub_hubbub/subscriber(.:format)" => "public#confirmation", cell: "nodes/pub_sub_hubbub"
    post "pub_sub_hubbub/subscriber(.:format)" => "public#subscription", cell: "nodes/pub_sub_hubbub"
  end

  page "rss" do
    get "page/:filename.:format" => "public#index", cell: "pages/page"
  end
end
