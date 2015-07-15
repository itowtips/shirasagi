module PublicBoard::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^board\//) }
  end

  class Topic
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "public_board/topic") }
  end
end
