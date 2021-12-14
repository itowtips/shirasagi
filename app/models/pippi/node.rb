module Pippi::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^pippi\//) }
  end

  class SkillJson
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "pippi/skill_json") }
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
