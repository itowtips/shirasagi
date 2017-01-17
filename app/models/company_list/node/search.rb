class CompanyList::Node::Search
  include Cms::Model::Node
  include Cms::Addon::NodeSetting
  include Cms::Addon::Meta
  include Event::Addon::PageList
  include Cms::Addon::Release
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  default_scope ->{ where(route: "company_list/search") }
end
