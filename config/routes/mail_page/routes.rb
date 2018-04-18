SS::Application.routes.draw do

  MailPage::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  content "mail_page" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, concerns: [:deletion]
  end

  node "mail_page" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "page/rss.xml" => "public#rss", cell: "nodes/page", format: "xml"
  end

  page "mail_page" do
    get "page/:filename.:format" => "public#index", cell: "pages/page"
  end

end
