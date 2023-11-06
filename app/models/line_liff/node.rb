module LineLiff::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^line_liff\//) }
  end

  class Page
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::GroupPermission
    include History::Addon::Backup
    include Cms::Lgwan::Node

    default_scope ->{ where(route: "line_liff/page") }
  end
end
