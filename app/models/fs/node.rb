module Fs::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^fs\//) }
  end

  class ImageViewer
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "fs/image_viewer") }
  end
end
