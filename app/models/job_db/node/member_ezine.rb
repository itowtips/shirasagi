class JobDb::Node::MemberEzine
  include Cms::Model::Node
  include Cms::Addon::NodeSetting
  include Cms::Addon::Meta
  include Ezine::Addon::SenderAddress
  include Ezine::Addon::Signature
  include Ezine::Addon::SubscriptionConstraint
  include Cms::Addon::PageList
  include Cms::Addon::Release
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  default_scope ->{ where(route: "job_db/member_ezine") }
end
