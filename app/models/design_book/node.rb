class DesignBook::Node
  include Cms::Model::Node
  include Cms::PluginRepository
  include Cms::Addon::NodeSetting
  include Cms::Addon::EditorSetting
  include Cms::Addon::GroupPermission
  include Cms::Addon::NodeAutoPostSetting
  include Cms::Addon::NodeLinePostSetting
  include Cms::Addon::ForMemberNode

  index({ site_id: 1, filename: 1 }, { unique: true })

  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^design_book\//) }
  end

  class Page
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::EditorSetting
    include Cms::Addon::NodeAutoPostSetting
    include Cms::Addon::NodeLinePostSetting
    include Event::Addon::PageList
    include Cms::Addon::Form::Node
    include Cms::Addon::Release
    include Cms::Addon::DefaultReleasePlan
    include Cms::Addon::MaxFileSizeSetting
    include Cms::Addon::GroupPermission
    include History::Addon::Backup
    include Cms::ChildList

    default_scope ->{ where(route: "design_book/page") }
  end
end
