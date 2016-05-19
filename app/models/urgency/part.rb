module Urgency::Part
  class Page
    include Cms::Model::Part
    include Cms::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "urgency/page") }
  end
end
