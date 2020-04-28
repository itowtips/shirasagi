module Idportal::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^idportal\//) }
  end

  class Page
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::EditorSetting
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "idportal/page") }
  end
end
