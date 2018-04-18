class MailPage::Page
  include Cms::Model::Page
  include Cms::Page::SequencedFilename
  include Cms::Addon::Meta
  include Cms::Addon::Body
  include Cms::Addon::File
  include Map::Addon::Page
  include Cms::Addon::RelatedPage
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  set_permission_name "mail_page_pages"

  default_scope ->{ where(route: "mail_page/page") }
end
