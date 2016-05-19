class Urgency::Page
  include Cms::Model::Page
  include Cms::Page::SequencedFilename
  include Cms::Addon::EditLock
  include Cms::Addon::Meta
  include Cms::Addon::Body
  include Urgency::Addon::Mail
  include Cms::Addon::File
  include Map::Addon::Page
  include Cms::Addon::RelatedPage
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  set_permission_name "cms_pages"

  default_scope ->{ where(route: "urgency/page") }
end
