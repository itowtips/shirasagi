module Pippi::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^pippi\//) }
  end

  class Tips
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "pippi/tips") }
  end
end
