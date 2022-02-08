class Riken::Auth::Shibboleth
  include Sys::Model::Auth
  include Sys::Addon::EnvironmentSetting
  include Riken::Addon::ShibbolethSetting
  include Sys::Permission

  set_permission_name "sys_users", :edit
  default_scope ->{ where(model: 'riken/auth/shibboleth') }

  def url(options = {})
    query = "?#{options.to_query}" if options.present?
    "/.mypage/login/shibboleth/#{filename}/login#{query}"
  end
end
