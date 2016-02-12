SS::Application.routes.draw do

  Member::Initializer

  concern :deletion do
    get :delete, :on => :member
    delete action: :destroy_all, :on => :collection
  end

  content "member" do
    get "/" => redirect { |p, req| "#{req.path}/logins" }, as: :main
    resources :logins, only: [:index]
    resources :mypages, concerns: :deletion
    resources :my_profiles, concerns: :deletion
    resources :my_blogs, concerns: :deletion
    resources :my_photos, concerns: :deletion
    resources :blog_layouts, concerns: :deletion
    resources :blogs, concerns: :deletion
    resources :blog_pages, concerns: :deletion

    resources :my_photos, concerns: :deletion
    resources :photos, concerns: :deletion do
      get :index_listable, on: :collection
      get :index_slideable, on: :collection
    end
    resources :photo_searches, concerns: :deletion
    resources :photo_categories, concerns: :deletion
    resources :photo_locations, concerns: :deletion
    resources :photo_spots, concerns: :deletion
  end

  node "member" do
    ## login
    match "login/(index.:format)" => "public#login", via: [:get, :post], cell: "nodes/login"
    match "login/login.html" => "public#login", via: [:get, :post], cell: "nodes/login"
    get "login/logout.html" => "public#logout", cell: "nodes/login"
    get "login/:provider/callback" => "public#callback", cell: "nodes/login"
    get "login/failure" => "public#failure", cell: "nodes/login"

    ## mypage node
    get "mypage/(index.:format)" => "public#index", cell: "nodes/mypage"

    ## public contents
    get "blog/(index.:format)" => "public#index", cell: "nodes/blog"
    get "blog/rss.xml" => "public#rss", cell: "nodes/blog", format: "xml"
    get "blog_page/(index.:format)" => "public#index", cell: "nodes/blog_page"
    get "blog_page/rss.xml" => "public#rss", cell: "nodes/blog_page", format: "xml"

    get "photo/(index.:format)" => "public#index", cell: "nodes/photo"
    get "photo_search/(index.:format)" => "public#index", cell: "nodes/photo_search"
    get "photo_search/map.html" => "public#map", cell: "nodes/photo_search"
    get "photo_category/(index.:format)" => "public#index", cell: "nodes/photo_category"
    get "photo_location/(index.:format)" => "public#index", cell: "nodes/photo_location"
    get "photo_spot/(index.:format)" => "public#index", cell: "nodes/photo_spot"

    ## mypage contents
    get "my_profile(index.:format)" => "public#index", cell: "nodes/my_profile"
    resource :my_profile, controller: "public", cell: "nodes/my_profile", only: [:edit, :update]
    get "my_profile/leave(.:format)" => "public#leave", cell: "nodes/my_profile"
    post "my_profile/confirm_leave(.:format)" => "public#confirm_leave", cell: "nodes/my_profile"
    post "my_profile/complete_leave(.:format)" => "public#complete_leave", cell: "nodes/my_profile"
    get "my_profile/change_password(.:format)" => "public#change_password", cell: "nodes/my_profile"
    post "my_profile/confirm_password(.:format)" => "public#confirm_password", cell: "nodes/my_profile"
    get "my_profile/complete_password(.:format)" => "public#complete_password", cell: "nodes/my_profile"

    scope "my_blog" do
      resource :setting, controller: "public", cell: "nodes/my_blog/setting", except: [:index, :show, :destroy]
    end
    get "my_blog(index.:format)" => "public#index", cell: "nodes/my_blog"
    resources :my_blog, concerns: :deletion, controller: "public", cell: "nodes/my_blog", except: :index

    get "my_photo(index.:format)" => "public#index", cell: "nodes/my_photo"
    resources :my_photo, controller: "public", cell: "nodes/my_photo", except: :index
  end

  page "member" do
    get "blog_page/:filename.:format" => "public#index", cell: "pages/blog_page"

    get "photo/:filename.:format" => "public#index", cell: "pages/photo"
    get "photo_spot/:filename.:format" => "public#index", cell: "pages/photo_spot"
  end

  part "member" do
    get "login" => "public#index", cell: "parts/login"
    get "blog_page" => "public#index", cell: "parts/blog_page"
    get "photo_slide" => "public#index", cell: "parts/photo_slide"
    get "photo_search" => "public#index", cell: "parts/photo_search"
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

  namespace "member", path: ".s:site/member", module: "member", servicer: /\d+/ do
    namespace "apis" do
      resources :photos, concerns: :deletion do
        get :select, on: :member
      end
    end
  end
end
