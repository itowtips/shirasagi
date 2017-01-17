SS::Application.routes.draw do

  CompanyList::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  concern :download do
    get :download, on: :collection
  end

  content "company_list" do
    get "/" => redirect { |p, req| "#{req.path}/searches" }, as: :main
    resources :searches, only: [:index, :show]
  end

  node "company_list" do
    get "search/(index.:format)" => "public#index", cell: "nodes/search"
    get "search/:filename/(index.:format)" => "public#show", cell: "nodes/search"
    get "search/rss.xml" => "public#rss", cell: "nodes/search", format: "xml"
  end
end
