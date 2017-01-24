class JobDb::Node::Login
  include Cms::Model::Node
  include Cms::Addon::NodeSetting
  include Cms::Addon::Meta
  include JobDb::Addon::Member::Applicant
  include Member::Addon::Redirection
  include Member::Addon::FormAuth
  include Member::Addon::TwitterOauth
  include Member::Addon::FacebookOauth
  include Member::Addon::YahooJpOauth
  include Member::Addon::GoogleOauth
  include Member::Addon::GithubOauth
  include Cms::Addon::Release
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  default_scope ->{ where(route: "job_db/login") }
end
