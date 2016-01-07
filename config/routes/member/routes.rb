SS::Application.routes.draw do

  Member::Initializer

  concern :deletion do
    get :delete, :on => :member
    delete action: :destroy_all, :on => :collection
  end

  content "member" do
    get "/" => redirect { |p, req| "#{req.path}/logins" }, as: :main
    resources :logins, only: [:index]
    resources :mypages
    resources :my_blogs
    resources :blog_layouts, concerns: :deletion
    resources :blogs, concerns: :deletion do
      resources :pages, controller: :blog_pages, concerns: :deletion
    end
  end

  node "member" do
    ## login
    get "login/(index.:format)" => "public#login", cell: "nodes/login"
    match "login/login.html" => "public#login", via: [:get, :post], cell: "nodes/login"
    get "login/logout.html" => "public#logout", cell: "nodes/login"
    get "login/:provider/callback" => "public#callback", cell: "nodes/login"
    get "login/failure" => "public#failure", cell: "nodes/login"

    ## mypage node
    get "mypage/(index.:format)" => "public#index", cell: "nodes/mypage"

    ## public contents
    get "blog/(index.:format)" => "public#index", cell: "nodes/blog"
    get "blog/:id/(index.:format)" => "public#show", cell: "nodes/blog", id: /\d+/
    get "blog/:id/rss.xml" => "public#rss", cell: "nodes/blog", format: "xml"
    get "blog/:id/page/:page_id/(index.:format)" => "public#show_page", cell: "nodes/blog", id: /\d+/, page_id: /\d+/

    ## mypage contents
    scope "my_blog" do
      resource :setting, controller: "public", cell: "nodes/my_blog/setting", except: [:index, :show, :destroy]
    end
    get "my_blog(index.:format)" => "public#index", cell: "nodes/my_blog"
    resources :my_blog, controller: "public", cell: "nodes/my_blog", except: :index
  end

  namespace "member", path: ".m:member", member: /\d+/ do
    namespace "apis" do
      resources :temp_files, concerns: :deletion do
        get :select, on: :member
        get :view, on: :member
        get :thumb, on: :member
        get :download, on: :member
      end
    end
  end
end
