SS::Application.routes.draw do

  Nices::Initializer

  concern :deletion do
    get :delete, :on => :member
    delete action: :destroy_all, :on => :collection
  end

  content "nices" do
    get "/" => redirect { |p, req| "#{req.path}/mypages" }, as: :main
    resources :mypages, concerns: :deletion
  end

  node "nices" do
    get "mypage/(index.:format)" => "public#index", cell: "nodes/mypage"
  end

end
