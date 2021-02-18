class DesignBook::Page
  include Cms::Model::Page
  include Cms::Addon::EditLock
  include Workflow::Addon::Branch
  include Workflow::Addon::Approver
  include Cms::Addon::Meta
  include Cms::Addon::SnsPoster
  include Gravatar::Addon::Gravatar
  include Cms::Addon::Thumb
  include Cms::Addon::Body
  include Cms::Addon::BodyPart
  include Cms::Addon::File
  include Cms::Addon::Form::Page
  include DesignBook::Addon::DesignBookNumber
  include Cms::Addon::ParentCrumb
  include Event::Addon::Date
  include Map::Addon::Page
  include Category::Addon::Category
  include Cms::Addon::RelatedPage
  include Contact::Addon::Page
  include Cms::Addon::Tag
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission
  include History::Addon::Backup
  include Cms::Addon::ForMemberPage

  default_scope ->{ where(route: "design_book/page") }
end
