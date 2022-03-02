Rails.application.routes.draw do

  # Riken::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  namespace "riken", path: ".sys" do
    namespace "auth" do
      resources :shibboleths, concerns: :deletion
    end
  end

  namespace "riken", path: ".mypage" do
    namespace "login" do
      # Shibboleth
      get "shibboleth/:id/login" => "shibboleth#login", as: :env
    end
  end

  # gws 'attendance' do
  # end
  namespace('riken', as: "gws_riken", path: ".g:site/riken", site: /\d+/) do
    namespace "ldap" do
      get "/" => redirect { |p, req| "#{req.path}/setting" }, as: :main
      resource :setting, only: %i[show edit update] do
        put :import, on: :member
      end
      resources :groups, only: %i[index]
      resources :users, only: %i[index]
    end
    namespace "ms365" do
      get "/" => redirect { |p, req| "#{req.path}/setting" }, as: :main
      resource :setting, only: %i[show edit update]
      namespace "diag" do
        resources :room_lists, only: %i[index] do
          resources :rooms, only: %i[index]
        end
        resources :rooms, only: %i[index]
        resources :events, only: %i[index new create]
      end
    end
    namespace "apis" do
      namespace "ldap" do
        post "test_connection" => "test#connection"
        post "test_group_search" => "test#group_search"
        post "test_user_search" => "test#user_search"
        post "test_custom_group_search" => "test#custom_group_search"
      end
      namespace "slack" do
        post "test_oauth_token" => "test#oauth_token"
        post "test_circular_slack_channels" => "test#circular_slack_channels"
        post "test_notice_slack_channels" => "test#notice_slack_channels"
      end
    end
  end
end
