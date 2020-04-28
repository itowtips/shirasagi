Rails.application.routes.draw do

  Idportal::Initializer

  content "idportal" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages
  end

  node "idportal" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "page/rss.xml" => "public#rss", cell: "nodes/page", format: "xml"
  end

end
