class Tourism::Page
  include Cms::Model::Page
  include Cms::Page::SequencedFilename
  include Cms::Addon::EditLock
  include Workflow::Addon::Branch
  include Workflow::Addon::Approver
  include Tourism::Addon::Facility
  include Cms::Addon::Meta
  include Cms::Addon::Thumb
  include Cms::Addon::Body
  include Cms::Addon::BodyPart
  include Cms::Addon::File
  include Cms::Addon::Form::Page
  include Category::Addon::Category
  include Cms::Addon::ParentCrumb
  include Map::Addon::Page
  include Cms::Addon::RelatedPage
  include Contact::Addon::Page
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission
  include Cms::AttachedFiles
  include History::Addon::Backup

  set_permission_name "tourism_pages"

  default_scope ->{ where(route: "tourism/page") }
end
